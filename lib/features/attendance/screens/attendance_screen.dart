import 'package:flutter/material.dart';
import '../../../features/auth/screens/profile_screen.dart';
import '../../../features/ranking/screens/ranking_screen.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  static const Color customBlue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double gridPadding = size.width * 0.05; // 5% of screen width
    final double gridItemSize = (size.width - (gridPadding * 2) - 16) / 2; // 2 columns

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.06), // 6% of screen height
        child: AppBar(
          title: Text(
            '자습실 출석체크',
            style: TextStyle(
              fontSize: size.width * 0.045, // 4.5% of screen width
            ),
          ),
          backgroundColor: customBlue,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.leaderboard,
                size: size.width * 0.06, // 6% of screen width
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RankingScreen(),
                  ),
                );
              },
              tooltip: '랭킹',
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                size: size.width * 0.06, // 6% of screen width
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              tooltip: '프로필',
            ),
            SizedBox(width: size.width * 0.02), // 2% of screen width
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              customBlue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(gridPadding),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: size.width * 0.04, // 4% of screen width
              crossAxisSpacing: size.width * 0.04, // 4% of screen width
              children: List.generate(4, (index) {
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          '출석체크',
                          style: TextStyle(
                            fontSize: size.width * 0.045, // 4.5% of screen width
                          ),
                        ),
                        content: Text(
                          '${index + 1}번 자리에 출석하시겠습니까?',
                          style: TextStyle(
                            fontSize: size.width * 0.04, // 4% of screen width
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(size.width * 0.03), // 3% of screen width
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: size.width * 0.035, // 3.5% of screen width
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(size.width * 0.02), // 2% of screen width
                              ),
                            ),
                            child: Text(
                              '확인',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.035, // 3.5% of screen width
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: gridItemSize,
                    height: gridItemSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.03), // 3% of screen width
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: size.width * 0.01, // 1% of screen width
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: size.width * 0.03, // 3% of screen width
                          top: size.width * 0.03, // 3% of screen width
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: size.width * 0.035, // 3.5% of screen width
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
} 