import 'package:flutter/material.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  static const Color customBlue = Color(0xFF2196F3);

  // 분 단위 시간을 "00시간 00분" 형식의 문자열로 변환
  String _formatDuration(int totalMinutes) {
    // TODO: 실제 데이터베이스에서 총 공부 시간(분)을 가져와서 계산
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분';
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
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.width * 0.02,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              // TODO: 실제 데이터베이스에서 사용자별 총 공부 시간을 가져와서 계산
              // 예시: totalMinutes = await StudyTimeRepository.getUserTotalMinutes(userId);
              final mockTotalMinutes = (10 - index) * 120; // 임시 데이터: 상위권일수록 더 많은 시간

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
                        color: index < 3 ? customBlue : Colors.grey[200],
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
                      '홍길동',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: itemHeight * 0.22,
                      ),
                    ),
                    subtitle: Text(
                      '1학년 2반 15번',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: itemHeight * 0.18,
                      ),
                    ),
                    trailing: Text(
                      _formatDuration(mockTotalMinutes),
                      style: TextStyle(
                        color: customBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: itemHeight * 0.2, // 시간 표시가 길어져서 폰트 크기 약간 감소
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 