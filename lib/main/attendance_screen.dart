import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'ranking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget _buildGridItem(BuildContext context, int index, Color bgColor, Size size, Color customBlue) {
  return InkWell(
    onTap: () async {
      final now = DateTime.now();
      final weekday = now.weekday; // 월=1, ..., 금=5, ..., 일=7

      // 시간 비교를 위한 함수
      bool isInRange(DateTime time, int startHour, int startMinute, int endHour, int endMinute) {
        final start = DateTime(time.year, time.month, time.day, startHour, startMinute);
        final end = DateTime(time.year, time.month, time.day, endHour, endMinute);
        return time.isAfter(start) && time.isBefore(end);
      }

      bool allowedTime = false;
      // TODO: 앱 테스트 목적으로 출첵 시간 제한 기능은 잠시 off
      // if (weekday >= 1 && weekday <= 4) {
      //   // 월~목
      //   allowedTime = isInRange(now, 15, 50, 18, 0) || isInRange(now, 19, 0, 23, 20);
      // } else if (weekday == 5) {
      //   // 금
      //   allowedTime = isInRange(now, 14, 50, 18, 0) || isInRange(now, 19, 0, 23, 20);
      // }

      // if (!allowedTime) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('현재는 자습실 운영 시간이 아닙니다.'),
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      //   return;
      // }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final seatsRef = FirebaseFirestore.instance.collection('seats');
      final seatDocRef = seatsRef.doc('${index + 1}');

      // 1. 현재 자리 문서 읽기
      final seatSnapshot = await seatDocRef.get();
      final seatData = seatSnapshot.data() as Map<String, dynamic>?;

      final seatUser = seatData?['user'] as String?;

      // 2. 현재 로그인 유저의 isStudying 상태 읽기
      final userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDocSnapshot.data() as Map<String, dynamic>?;

      final isStudying = userData?['isStudying'] as bool? ?? false;

      // 3. 조건 체크: 이미 출석 중(isStudying == true) 이고, 클릭한 자리가 본인 자리(user == uid) 아니면 dialog 안 띄우기
      if (isStudying && seatUser != uid) {
        // 그냥 리턴 (아무 액션 없음)
        return;
      }

      if (!isStudying && seatUser != null && seatUser != uid) {
        // 아직 출석 안했는데 다른 사람이 앉은 자리 누름 → SnackBar 출력 후 return
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('다른 사용자가 이미 출석 중인 자리입니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 4. 기존 AlertDialog 로직

      final isOccupied = seatUser != null;

      final message = isOccupied
          ? '${index + 1}번 자리를 비우시겠습니까?'
          : '${index + 1}번 자리에 출석하시겠습니까?';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            '출석체크',
            style: TextStyle(fontSize: size.width * 0.045),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: size.width * 0.04),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
          ),
          actions: [
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(fontSize: size.width * 0.035),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: customBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
              ),
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.035,
                ),
              ),
                onPressed: () async {
                  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

                  if (isOccupied) {
                    // 🔸 출석 해제
                    final userSnapshot = await userRef.get();
                    final userData = userSnapshot.data();

                    if (userData != null && userData['checkInTime'] != null) {
                      final checkInTimestamp = userData['checkInTime'] as Timestamp;
                      final checkInTime = checkInTimestamp.toDate();
                      final now = DateTime.now();

                      final duration = now.difference(checkInTime);
                      final minutes = (duration.inSeconds / 60).round(); // 반올림

                      final currentStudyTime = userData['studyTime'] ?? 0;
                      final updatedStudyTime = currentStudyTime + minutes;

                      await userRef.update({
                        'isStudying': false,
                        'checkInTime': FieldValue.delete(),
                        'studyTime': updatedStudyTime,
                      });
                    } else {
                      await userRef.update({'isStudying': false});
                    }

                    await seatDocRef.update({'user': null});
                  } else {
                    // 🔹 출석 시작
                    await userRef.update({
                      'isStudying': true,
                      'checkInTime': DateTime.now(),
                    });

                    await seatDocRef.update({'user': uid});
                  }

                  Navigator.pop(context);
                }

            ),
          ],
        ),
      );
    },
    child: Container(
      width: (size.width - (size.width * 0.05 * 2) - 16) / 2,
      height: (size.width - (size.width * 0.05 * 2) - 16) / 2,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: size.width * 0.01,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
           left: size.width * 0.03,
            top: size.width * 0.03,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        ]
      ),
    ),
  );
}


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
              crossAxisCount: 3,
              mainAxisSpacing: size.width * 0.04, // 4% of screen width
              crossAxisSpacing: size.width * 0.04, // 4% of screen width
              children: List.generate(9, (index) {
                final seatDocStream = FirebaseFirestore.instance
                    .collection('seats')
                    .doc('${index + 1}')
                    .snapshots();

                return StreamBuilder<DocumentSnapshot>(
                  stream: seatDocStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _buildGridItem(context, index, Colors.white, size, customBlue);
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;

                    // user 필드가 null이 아니면 초록색, null이면 흰색
                    final isOccupied = data != null && data['user'] != null;

                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final seatUserId = data?['user'] as String?;

                    final color = switch (seatUserId) {
                      null => Colors.white, // 빈 자리
                      final id when id == uid => Color(0xff2db400)!, // 내가 앉은 자리
                      _ => Colors.yellow! // 다른 사람이 앉은 자리
                    };

                    return _buildGridItem(context, index, color, size, customBlue);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
} 