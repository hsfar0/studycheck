import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  static const Color customBlue = Color(0xFF2196F3);

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0 && minutes == 0) {
      return '0시간';
    } else if (hours == 0) {
      return '${minutes}분';
    } else if (minutes == 0) {
      return '${hours}시간';
    } else {
      return '${hours}시간 ${minutes}분';
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = size.height - padding.top - padding.bottom - (size.height * 0.06);
    final itemHeight = (availableHeight - (size.width * 0.08)) / 10;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.06),
        child: AppBar(
          title: Text(
            '출석 랭킹',
            style: TextStyle(
              fontSize: size.width * 0.045,
            ),
          ),
          backgroundColor: customBlue,
          elevation: 0,
          centerTitle: true,
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
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .orderBy('studyTime', descending: true)
                .limit(10)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.width * 0.02,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final name = user['name'] ?? '이름 없음';
                  final userClass = user['class'] ?? '';
                  final number = user['number'] ?? '';
                  final studyTime = user['studyTime'] ?? 0;

                  return SizedBox(
                    height: itemHeight,
                    child: Card(
                      elevation: 1,
                      margin: EdgeInsets.only(
                        bottom: size.width * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.03,
                        ),
                        leading: Container(
                          width: itemHeight * 0.5,
                          height: itemHeight * 0.5,
                          decoration: BoxDecoration(
                            color: () {
                              if (index == 0) return const Color(0xFFFFD700);
                              if (index == 1) return const Color(0xFFC0C0C0);
                              if (index == 2) return const Color(0xFFCD7F32);
                              return Colors.grey[200];
                            }(),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index < 3 ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: itemHeight * 0.25,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: itemHeight * 0.22,
                          ),
                        ),
                        subtitle: Text(
                          '${user['grade']}학년 ${user['class']}반 ${user['number']}번',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: itemHeight * 0.18,
                          ),
                        ),
                        trailing: Text(
                          _formatDuration(studyTime),
                          style: TextStyle(
                            color: customBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: itemHeight * 0.2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
