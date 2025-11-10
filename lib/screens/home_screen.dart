import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/bottom_navigation.dart';
import 'package:frontend/widgets/common/top_bar.dart';
import 'package:frontend/widgets/home/home_empty_message.dart';
import 'package:frontend/widgets/home/home_register_yacht_button.dart';
import 'package:frontend/screens/create1_yacht_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HooaahTopBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            const HomeEmptyMessage(),
            const SizedBox(height: 24),
            HomeRegisterYachtButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Create1YachtScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: HooaahBottomNavigation(
        currentTab: HooaahTab.home,
        onTabSelected: (tab) {
          if (tab == HooaahTab.home) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('해당 기능은 준비 중입니다.'),
            ),
          );
        },
      ),
    );
  }
}
