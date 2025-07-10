import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rankings = [];

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분';
  }

  Future<void> _loadRankings() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final attendanceSnapshot = await FirebaseFirestore.instance.collection('attendance').get();

      final Map<String, int> studyMinutes = {};
      
      // 각 사용자별 공부 시간 계산 (분 단위)
      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final checkInTime = (data['checkInTime'] as Timestamp).toDate();
        final checkOutTime = data['checkOutTime'] != null 
            ? (data['checkOutTime'] as Timestamp).toDate()
            : DateTime.now(); // 체크아웃하지 않은 경우 현재 시간까지 계산
        
        final duration = checkOutTime.difference(checkInTime).inMinutes;
        studyMinutes[userId] = (studyMinutes[userId] ?? 0) + duration;
      }

      // 사용자 정보와 공부 시간 결합
      final List<Map<String, dynamic>> rankings = [];
      for (var doc in usersSnapshot.docs) {
        final userData = doc.data();
        final userId = doc.id;
        rankings.add({
          'userId': userId,
          'name': userData['name'],
          'grade': userData['grade'],
          'class': userData['class'],
          'number': userData['number'],
          'studyMinutes': studyMinutes[userId] ?? 0,
        });
      }

      // 공부 시간으로 정렬
      rankings.sort((a, b) => b['studyMinutes'].compareTo(a['studyMinutes']));

      if (mounted) {
        setState(() {
          _rankings = rankings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('랭킹 정보를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.06),
        child: AppBar(
          title: Text(
            '자습실 랭킹',
            style: TextStyle(
              fontSize: size.width * 0.045,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
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
              AppTheme.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadRankings,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.02,
                  ),
                  itemCount: _rankings.length,
                  itemBuilder: (context, index) {
                    final ranking = _rankings[index];
                    final isTopThree = index < 3;

                    return Card(
                      elevation: isTopThree ? 4 : 1,
                      margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: size.width * 0.1,
                          height: size.width * 0.1,
                          decoration: BoxDecoration(
                            color: isTopThree
                                ? [Colors.amber, Colors.grey[300], Colors.brown][index]
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isTopThree ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * 0.04,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          ranking['name'],
                          style: TextStyle(
                            fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                        subtitle: Text(
                          '${ranking['grade']}학년 ${ranking['class']}반 ${ranking['number']}번',
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(size.width * 0.02),
                          ),
                          child: Text(
                            _formatDuration(ranking['studyMinutes']),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.035,
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