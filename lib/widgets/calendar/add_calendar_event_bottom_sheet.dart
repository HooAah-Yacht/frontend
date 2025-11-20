import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:frontend/widgets/common/custom_text_field.dart';
import 'package:frontend/widgets/common/custom_picker.dart';
import 'package:frontend/widgets/common/custom_button.dart';
import 'package:frontend/services/yacht_service.dart';
import 'package:frontend/services/part_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/calendar_service.dart';
import 'package:http/http.dart' as http;

class AddCalendarEventBottomSheet extends StatefulWidget {
  const AddCalendarEventBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialData,
  });

  final ValueChanged<Map<String, dynamic>> onSubmit;
  final Map<String, dynamic>? initialData;

  @override
  State<AddCalendarEventBottomSheet> createState() => _AddCalendarEventBottomSheetState();
}

class _AddCalendarEventBottomSheetState extends State<AddCalendarEventBottomSheet> {
  // 완료 여부
  bool _completed = false;
  
  // 요트 선택
  String? _selectedYachtId;
  String? _selectedYachtDisplay;
  List<Map<String, dynamic>> _yachtList = [];
  bool _isLoadingYachts = true;
  
  // 일정 구분
  String? _selectedType;
  List<String> _typeOptions = [];
  bool _isLoadingTypes = true;
  String? _typeError;
  
  // 부품 선택 (정비 선택 시)
  List<Map<String, dynamic>> _partList = [];
  String? _selectedPartId;
  String? _selectedPartName;
  bool _isLoadingParts = false;
  
  // 내용
  final TextEditingController _contentController = TextEditingController();
  String? _contentError;
  
  // 하루종일
  bool _allDay = false;
  
  // 시작 날짜/시간
  DateTime? _startDate;
  TimeOfDay? _startTime;
  
  // 종료 날짜/시간
  DateTime? _endDate;
  TimeOfDay? _endTime;
  
  // 참조인 (email을 식별자로 사용)
  List<String> _selectedCc = [];
  List<String> _tempSelectedCc = []; // 임시 선택 (완료 버튼 누르면 반영)
  List<Map<String, dynamic>> _memberList = [];
  bool _isLoadingMembers = true;
  String? _currentUserEmail; // 현재 사용자 email

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    
    if (widget.initialData == null) {
      // 등록 모드: 기본값 설정
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = DateTime(now.year, now.month, now.day);
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now();
    }
  }

  Future<void> _initializeFromData(Map<String, dynamic> data) async {
    setState(() {
      _completed = data['completed'] as bool? ?? false;
      
      final startDateStr = data['startDate'] as String?;
      final endDateStr = data['endDate'] as String?;
      
      if (startDateStr != null) {
        final startDate = DateTime.parse(startDateStr).toLocal();
        _startDate = DateTime(startDate.year, startDate.month, startDate.day);
        _startTime = TimeOfDay(hour: startDate.hour, minute: startDate.minute);
      }
      
      if (endDateStr != null) {
        final endDate = DateTime.parse(endDateStr).toLocal();
        _endDate = DateTime(endDate.year, endDate.month, endDate.day);
        _endTime = TimeOfDay(hour: endDate.hour, minute: endDate.minute);
      }
      
      final type = data['type'] as String?;
      if (type != null) {
        _selectedType = _convertApiTypeToDisplay(type);
      }
      
      final content = data['content'] as String?;
      if (content != null) {
        _contentController.text = content;
      }
    });
    
    // 요트 목록 로드 후 초기화
    final yachtId = data['yachtId'] as int?;
    if (yachtId != null && _yachtList.isNotEmpty) {
      final yacht = _yachtList.firstWhere(
        (y) => (y['id'] as num?)?.toInt() == yachtId,
        orElse: () => <String, dynamic>{},
      );
      if (yacht.isNotEmpty) {
        _onYachtSelected(yacht);
        
        // 부품 정보 설정
        final partId = data['partId'] as int?;
        if (partId != null && _selectedType == '정비') {
          await _loadPartList(yachtId);
          final part = _partList.firstWhere(
            (p) => (p['id'] as num?)?.toInt() == partId,
            orElse: () => <String, dynamic>{},
          );
          if (part.isNotEmpty) {
            final partName = part['name'] as String? ?? '';
            setState(() {
              _selectedPartId = partId.toString();
              _selectedPartName = partName;
            });
          }
        }
      }
    }
  }

  String? _convertApiTypeToDisplay(String? apiType) {
    if (apiType == null) return null;
    switch (apiType.toUpperCase()) {
      case 'SAILING':
        return '세일링';
      case 'INSPECTION':
        return '점검';
      case 'PART':
        return '정비';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadCurrentUser();
    await Future.wait([
      _loadYachtList(),
    ]);
  }

  // 현재 사용자 정보를 가져와서 참조인 선택 시 본인을 제외하기 위해 사용
  // 참조인은 작성자인 나를 제외한 다른 멤버만 선택할 수 있어야 함
  Future<void> _loadCurrentUser() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      final url = '${AuthService.baseUrl}/api/user';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.trim()}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
        if (responseData != null) {
          setState(() {
            _currentUserEmail = responseData['email'] as String?;
          });
        }
      }
    } catch (e) {
      print('현재 사용자 정보 로드 실패: $e');
    }
  }

  Future<void> _loadYachtList() async {
    try {
      setState(() {
        _isLoadingYachts = true;
      });

      final yachts = await YachtService.getYachtList();
      
      setState(() {
        _yachtList = yachts;
        _isLoadingYachts = false;
      });
      
      // 요트 목록이 있으면 처리
      if (_yachtList.isNotEmpty) {
        // 수정 모드이고 요트 ID가 있으면 해당 요트 선택
        if (widget.initialData != null) {
          await _initializeFromData(widget.initialData!);
        } else {
          // 등록 모드: 첫 번째 요트 선택
          _onYachtSelected(_yachtList.first);
        }
      }
    } catch (e) {
      print('요트 목록 로드 실패: $e');
      setState(() {
        _isLoadingYachts = false;
      });
    }
  }

  Future<void> _loadMemberList() async {
    if (_selectedYachtId == null) {
      setState(() {
        _isLoadingMembers = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoadingMembers = true;
      });

      final yachtId = int.tryParse(_selectedYachtId ?? '');
      if (yachtId != null) {
        final members = await YachtService.getYachtUserList(yachtId);
        
        setState(() {
          _memberList = members;
          _isLoadingMembers = false;
        });
      } else {
        setState(() {
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      print('멤버 목록 로드 실패: $e');
      setState(() {
        _isLoadingMembers = false;
      });
    }
  }

  Future<void> _loadTypeOptions(int yachtId) async {
    try {
      setState(() {
        _isLoadingTypes = true;
      });

      final parts = await PartService.getPartListByYacht(yachtId);
      
      setState(() {
        _typeOptions = ['세일링', '점검', '정비'];
        _partList = parts;
        _isLoadingTypes = false;
      });
    } catch (e) {
      print('타입 옵션 로드 실패: $e');
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }
  
  Future<void> _loadPartList(int yachtId) async {
    try {
      setState(() {
        _isLoadingParts = true;
      });

      final parts = await PartService.getPartListByYacht(yachtId);
      
      setState(() {
        _partList = parts;
        _isLoadingParts = false;
      });
    } catch (e) {
      print('부품 목록 로드 실패: $e');
      setState(() {
        _isLoadingParts = false;
      });
    }
  }
  
  // 타입 표시값을 API 값으로 변환
  String? _convertTypeToApiValue(String? displayType) {
    if (displayType == null) return null;
    switch (displayType) {
      case '세일링':
        return 'SAILING';
      case '점검':
        return 'INSPECTION';
      case '정비':
        return 'PART';
      default:
        return null;
    }
  }

  void _onYachtSelected(Map<String, dynamic> yacht) {
    final yachtId = (yacht['id'] as num?)?.toInt();
    final yachtName = yacht['name'] as String? ?? '';
    final yachtAlias = yacht['nickName'] as String?;
    
    setState(() {
      _selectedYachtId = yachtId?.toString();
      _selectedYachtDisplay = yachtAlias != null && yachtAlias.isNotEmpty 
          ? '$yachtAlias[$yachtName]' 
          : yachtName;
      // 수정 모드가 아니면 타입 초기화
      if (widget.initialData == null) {
        _selectedType = null;
        _selectedPartId = null;
        _selectedPartName = null;
      }
    });
    
    if (yachtId != null) {
      _loadTypeOptions(yachtId);
      _loadMemberList();
    }
  }

  Future<void> _showTimePicker(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // 변경사항이 있는지 확인
  bool _hasChanges() {
    if (widget.initialData == null) return true; // 등록 모드는 항상 변경사항 있음
    
    final original = widget.initialData!;
    
    final apiType = _convertTypeToApiValue(_selectedType);
    final originalType = original['type'] as String?;
    if (apiType != originalType) return true;
    
    final yachtId = int.tryParse(_selectedYachtId ?? '');
    final originalYachtId = original['yachtId'] as int?;
    if (yachtId != originalYachtId) return true;
    
    final partId = _selectedPartId != null ? int.parse(_selectedPartId!) : null;
    final originalPartId = original['partId'] as int?;
    if (partId != originalPartId) return true;
    
    if (_completed != (original['completed'] as bool? ?? false)) return true;
    
    final content = _contentController.text.trim();
    final originalContent = original['content'] as String? ?? '';
    if (content != originalContent) return true;
    
    final startDateStr = original['startDate'] as String?;
    final endDateStr = original['endDate'] as String?;
    
    if (startDateStr != null) {
      final originalStartDate = DateTime.parse(startDateStr).toLocal();
      final newStartDateTime = _allDay
          ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0)
          : DateTime(
              _startDate!.year,
              _startDate!.month,
              _startDate!.day,
              _startTime!.hour,
              _startTime!.minute,
            );
      
      if (originalStartDate.year != newStartDateTime.year ||
          originalStartDate.month != newStartDateTime.month ||
          originalStartDate.day != newStartDateTime.day ||
          originalStartDate.hour != newStartDateTime.hour ||
          originalStartDate.minute != newStartDateTime.minute) {
        return true;
      }
    }
    
    if (endDateStr != null) {
      final originalEndDate = DateTime.parse(endDateStr).toLocal();
      final newEndDateTime = _allDay
          ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59)
          : DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              _endTime!.hour,
              _endTime!.minute,
            );
      
      if (originalEndDate.year != newEndDateTime.year ||
          originalEndDate.month != newEndDateTime.month ||
          originalEndDate.day != newEndDateTime.day ||
          originalEndDate.hour != newEndDateTime.hour ||
          originalEndDate.minute != newEndDateTime.minute) {
        return true;
      }
    }
    
    return false;
  }

  Future<void> _handleSubmit() async {
    // 수정 모드이고 변경사항이 없으면 그냥 닫기
    if (widget.initialData != null && !_hasChanges()) {
      Navigator.of(context).pop();
      return;
    }
    
    // 수정 모드이고 변경사항이 있으면 확인 다이얼로그
    if (widget.initialData != null && _hasChanges()) {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('일정 수정'),
          content: const Text('정말 수정하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('수정'),
            ),
          ],
        ),
      );
      
      if (shouldProceed != true) {
        return;
      }
    }
    
    // 에러 메시지 초기화
    setState(() {
      _typeError = null;
      _contentError = null;
    });

    // 유효성 검사
    bool hasError = false;

    if (_selectedYachtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('요트를 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      hasError = true;
    }

    if (_selectedType == null) {
      setState(() {
        _typeError = '일정 구분을 선택해주세요.';
      });
      hasError = true;
    }
    
    // 정비 선택 시 부품 선택 필수
    if (_selectedType == '정비' && _selectedPartId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('정비를 선택한 경우 부품을 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      hasError = true;
    }

    if (_contentController.text.trim().isEmpty) {
      setState(() {
        _contentError = '내용을 입력해주세요.';
      });
      hasError = true;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('시작 날짜와 종료 날짜를 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      hasError = true;
    }

    if (!_allDay && (_startTime == null || _endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('시작 시간과 종료 시간을 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      hasError = true;
    }

    if (hasError) {
      return;
    }

    final startDateTime = _allDay
        ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0)
        : DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            _startTime!.hour,
            _startTime!.minute,
          );

    final endDateTime = _allDay
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59)
        : DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
            _endTime!.hour,
            _endTime!.minute,
          );

    // CalendarCreateRequest 형식에 맞춰서 데이터 구성
    final apiType = _convertTypeToApiValue(_selectedType);
    final yachtId = int.parse(_selectedYachtId!);
    
    final payload = {
      'type': apiType,
      'yachtId': yachtId,
      'startDate': startDateTime.toUtc().toIso8601String(),
      'endDate': endDateTime.toUtc().toIso8601String(),
      'completed': _completed,
      'byUser': true, // 사용자가 직접 생성한 일정
      'content': _contentController.text.trim(),
      'partId': _selectedPartId != null ? int.parse(_selectedPartId!) : null,
    };

    // JSON 형식으로 콘솔에 출력
    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('일정 등록 JSON:');
    debugPrint(encoder.convert(payload));

    // API 호출
    final result = await CalendarService.createCalendar(
      type: apiType!,
      yachtId: yachtId,
      startDate: startDateTime.toUtc().toIso8601String(),
      endDate: endDateTime.toUtc().toIso8601String(),
      completed: _completed,
      byUser: true,
      content: _contentController.text.trim(),
      partId: _selectedPartId != null ? int.parse(_selectedPartId!) : null,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('일정이 등록되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onSubmit(payload);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? '일정 등록에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 완료 여부 토글
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF47546F),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '완료 여부',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: -0.5,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _completed = !_completed;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: _completed ? const Color(0xFF87C149) : const Color(0xFFB0B8C1),
                            ),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  left: _completed ? 19 : 1,
                                  top: 1,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 요트 선택
                  if (_isLoadingYachts)
                    const Center(child: CircularProgressIndicator())
                  else
                    CustomPicker(
                      items: _yachtList.map((yacht) {
                        final yachtName = yacht['name'] as String? ?? '';
                        final yachtAlias = yacht['nickName'] as String?;
                        return yachtAlias != null && yachtAlias.isNotEmpty 
                            ? '$yachtAlias[$yachtName]' 
                            : yachtName;
                      }).toList(),
                      hintText: '요트 선택',
                      selectedValue: _selectedYachtDisplay,
                      onSelected: (value) {
                        final index = _yachtList.indexWhere((yacht) {
                          final yachtName = yacht['name'] as String? ?? '';
                          final yachtAlias = yacht['nickName'] as String?;
                          final display = yachtAlias != null && yachtAlias.isNotEmpty 
                              ? '$yachtAlias[$yachtName]' 
                              : yachtName;
                          return display == value;
                        });
                        if (index != -1) {
                          _onYachtSelected(_yachtList[index]);
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  
                  // 일정 구분
                  if (_isLoadingTypes)
                    const Center(child: CircularProgressIndicator())
                  else
                    CustomPicker(
                      items: _typeOptions,
                      hintText: '일정 구분',
                      selectedValue: _selectedType,
                      onSelected: (value) {
                        setState(() {
                          _selectedType = value;
                          _typeError = null; // 선택 시 에러 메시지 제거
                          // 정비가 아닌 경우 부품 선택 초기화
                          if (value != '정비') {
                            _selectedPartId = null;
                            _selectedPartName = null;
                          } else {
                            // 정비 선택 시 부품 목록 로드
                            final yachtId = int.tryParse(_selectedYachtId ?? '');
                            if (yachtId != null && _partList.isEmpty) {
                              _loadPartList(yachtId);
                            }
                          }
                        });
                      },
                    ),
                  if (_typeError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _typeError!,
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: -0.5,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  // 정비 선택 시 부품 선택 UI 표시
                  if (_selectedType == '정비') ...[
                    const SizedBox(height: 12),
                    if (_isLoadingParts)
                      const Center(child: CircularProgressIndicator())
                    else
                      CustomPicker(
                        items: _partList.map((part) {
                          final name = part['name'] as String? ?? '';
                          return name;
                        }).toList(),
                        hintText: '부품 선택',
                        selectedValue: _selectedPartName,
                        onSelected: (value) {
                          final selectedPart = _partList.firstWhere(
                            (part) => (part['name'] as String? ?? '') == value,
                            orElse: () => <String, dynamic>{},
                          );
                          final partId = (selectedPart['id'] as num?)?.toInt();
                          setState(() {
                            _selectedPartName = value;
                            _selectedPartId = partId?.toString();
                          });
                        },
                      ),
                  ],
                  const SizedBox(height: 12),
                  
                  // 제목
                  CustomTextField(
                    controller: _contentController,
                    hintText: '내용',
                    onChanged: (value) {
                      if (_contentError != null && value.trim().isNotEmpty) {
                        setState(() {
                          _contentError = null; // 입력 시 에러 메시지 제거
                        });
                      }
                    },
                  ),
                  if (_contentError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _contentError!,
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: -0.5,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  
                  // 하루종일 토글 + 시작/종료 날짜/시간
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF47546F),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 하루종일 토글
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '하루종일',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: -0.5,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _allDay = !_allDay;
                                  // 하루종일이 활성화되면 시간을 자동으로 설정
                                  if (_allDay) {
                                    _startTime = const TimeOfDay(hour: 0, minute: 0);
                                    _endTime = const TimeOfDay(hour: 23, minute: 59);
                                  }
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: _allDay ? const Color(0xFF87C149) : const Color(0xFFB0B8C1),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      left: _allDay ? 19 : 1,
                                      top: 1,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 시작 날짜
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '시작 날짜',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: -0.5,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet<DateTime>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      builder: (sheetContext) {
                                        return _DatePickerBottomSheet(
                                          initialDate: _startDate ?? DateTime.now(),
                                          onDateSelected: (date) {
                                            setState(() {
                                              _startDate = DateTime(date.year, date.month, date.day);
                                            });
                                            Navigator.of(sheetContext).pop(date);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F9FE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _startDate != null
                                          ? '${_startDate!.year}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.day.toString().padLeft(2, '0')}'
                                          : '날짜 선택',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        letterSpacing: -0.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!_allDay) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _showTimePicker(context, true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F9FE),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _startTime != null
                                            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                            : '시간 선택',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: -0.5,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 종료 날짜
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '종료 날짜',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: -0.5,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet<DateTime>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      builder: (sheetContext) {
                                        return _DatePickerBottomSheet(
                                          initialDate: _endDate ?? DateTime.now(),
                                          onDateSelected: (date) {
                                            setState(() {
                                              _endDate = DateTime(date.year, date.month, date.day);
                                            });
                                            Navigator.of(sheetContext).pop(date);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F9FE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _endDate != null
                                          ? '${_endDate!.year}.${_endDate!.month.toString().padLeft(2, '0')}.${_endDate!.day.toString().padLeft(2, '0')}'
                                          : '날짜 선택',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        letterSpacing: -0.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!_allDay) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _showTimePicker(context, false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F9FE),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _endTime != null
                                            ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                                            : '시간 선택',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: -0.5,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 참조인
                  GestureDetector(
                    onTap: () => _showMemberPicker(context),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF47546F),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: _selectedCc.isEmpty
                          ? Text(
                              '참조인',
                              style: const TextStyle(
                                fontSize: 16,
                                letterSpacing: -0.5,
                                color: Color(0xFF47546F),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedCc.map((memberEmail) {
                                final member = _memberList.firstWhere(
                                  (m) => (m['email'] as String?) == memberEmail,
                                  orElse: () => <String, dynamic>{},
                                );
                                final name = member['name'] as String? ?? '';
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F9FE),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          letterSpacing: -0.5,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedCc.remove(memberEmail);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 등록하기/수정하기 버튼
                  CustomButton(
                    text: widget.initialData != null ? '수정하기' : '등록하기',
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
          // 취소 아이콘
          Positioned(
            top: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SvgPicture.asset(
                'assets/image/cancel_icon.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMemberPicker(BuildContext context) async {
    if (_selectedYachtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 요트를 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 현재 선택된 값으로 임시 선택 초기화
    _tempSelectedCc = List<String>.from(_selectedCc);

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        // 현재 사용자 제외한 멤버 목록
        final filteredMembers = _memberList.where((member) {
          final email = member['email'] as String? ?? '';
          return email.isNotEmpty && email != _currentUserEmail;
        }).toList();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '참조인 선택',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // 완료 버튼: 임시 선택을 실제 선택으로 반영
                            setState(() {
                              _selectedCc = List<String>.from(_tempSelectedCc);
                            });
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text(
                            '완료',
                            style: TextStyle(letterSpacing: -0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoadingMembers
                        ? const Center(child: CircularProgressIndicator())
                        : filteredMembers.isEmpty
                            ? const Center(
                                child: Text(
                                  '참조할 멤버가 없습니다.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: -0.5,
                                    color: Color(0xFFB0B8C1),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredMembers.length,
                                itemBuilder: (context, index) {
                                  final member = filteredMembers[index];
                                  final email = member['email'] as String? ?? '';
                                  final name = member['name'] as String? ?? '';
                                  final isSelected = email.isNotEmpty && _tempSelectedCc.contains(email);

                                  return CheckboxListTile(
                                    title: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    subtitle: Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        letterSpacing: -0.5,
                                        color: Color(0xFFB0B8C1),
                                      ),
                                    ),
                                    value: isSelected,
                                    onChanged: (value) {
                                      setModalState(() {
                                        if (email.isNotEmpty) {
                                          if (value == true) {
                                            if (!_tempSelectedCc.contains(email)) {
                                              _tempSelectedCc.add(email);
                                            }
                                          } else {
                                            _tempSelectedCc.remove(email);
                                          }
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// 날짜 선택 bottom sheet
class _DatePickerBottomSheet extends StatefulWidget {
  const _DatePickerBottomSheet({
    required this.initialDate,
    required this.onDateSelected,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late int _tempYear;
  late int _tempMonth;
  late int _tempDay;

  int _daysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }

  @override
  void initState() {
    super.initState();
    _tempYear = widget.initialDate.year;
    _tempMonth = widget.initialDate.month;
    _tempDay = widget.initialDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = List<int>.generate(
      _daysInMonth(_tempYear, _tempMonth),
      (index) => index + 1,
    );

    if (_tempDay > days.last) {
      _tempDay = days.last;
    }

    final now = DateTime.now();
    final years = List<int>.generate(51, (index) => now.year - index);
    const months = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    return SizedBox(
      height: 320,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '취소',
                    style: TextStyle(letterSpacing: -0.5),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onDateSelected(DateTime(_tempYear, _tempMonth, _tempDay));
                  },
                  child: const Text(
                    '완료',
                    style: TextStyle(letterSpacing: -0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: years.indexOf(_tempYear),
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _tempYear = years[index];
                        final newDays = _daysInMonth(_tempYear, _tempMonth);
                        if (_tempDay > newDays) {
                          _tempDay = newDays;
                        }
                      });
                    },
                    children: years
                        .map(
                          (year) => Center(
                            child: Text(
                              '$year년',
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: -0.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: _tempMonth - 1,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _tempMonth = months[index];
                        final newDays = _daysInMonth(_tempYear, _tempMonth);
                        if (_tempDay > newDays) {
                          _tempDay = newDays;
                        }
                      });
                    },
                    children: months
                        .map(
                          (month) => Center(
                            child: Text(
                              '$month월',
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: -0.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: _tempDay - 1,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _tempDay = days[index];
                      });
                    },
                    children: days
                        .map(
                          (day) => Center(
                            child: Text(
                              '$day일',
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: -0.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

