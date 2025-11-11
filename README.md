# frontend
## 실행 방법
해당 폴더 경로 터미널에서 flutter run >> 시뮬레이터가 켜져있으면 자동으로 연결, 아니라면 chrome으로 연결 가능

## 요트 등록
- 요트 등록 완료되었을 때의 payload 구조 (api구조에 맞춰 수정 가능)

```json
{
  yachtName: "요트 종류",
  yachtAlias: "요트 별칭",
  parts: {
            name: "장비명",
            manufacturer: "제조사",
            model: "모델명",
            latestMaintenanceDate: "최근 정비일",
            interval: "정비 주기",
          },
)
```
