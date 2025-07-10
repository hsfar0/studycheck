import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color customBlue = Color(0xFF2196F3);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String? email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.06),
        child: AppBar(
          title: Text(
            '계정 관리',
            style: TextStyle(fontSize: size.width * 0.045),
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
          child: ListView(
            padding: EdgeInsets.all(size.width * 0.04),
            children: [
              // ——— 여기에 사용자 정보 표시 위젯 추가 ———
              FutureBuilder<Map<String, dynamic>?>(
                future: _fetchUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox(); // 데이터 없으면 빈 공간
                  }
                  final data = snapshot.data!;
                  final grade = data['grade'] ?? '-';
                  final userClass = data['class'] ?? '-';
                  final number = data['number'] ?? '-';
                  final name = data['name'] ?? '-';

                  return Container(
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                      horizontal: size.width * 0.04,
                    ),
                    margin: EdgeInsets.only(bottom: size.height * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: size.width * 0.02,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '내 정보',
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: customBlue,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text('이메일: ${email ?? "알 수 없음"}', style: TextStyle(fontSize: size.width * 0.04)),
                        Text('이름: $name', style: TextStyle(fontSize: size.width * 0.04)),
                        Text('학년: $grade', style: TextStyle(fontSize: size.width * 0.04)),
                        Text('반: $userClass', style: TextStyle(fontSize: size.width * 0.04)),
                        Text('번호: $number', style: TextStyle(fontSize: size.width * 0.04)),
                      ],
                    ),
                  );
                },
              ),

              // 기존 메뉴 아이템들
              const Divider(height: 1,),
              _buildMenuItem(
                context,
                icon: Icons.lock,
                title: '비밀번호 변경',
                onTap: () {
                  Navigator.of(context).pushNamed('/changepw');
                  // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
              const Divider(height: 1),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, size.height * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.02),
                    ),
                  ),
                  onPressed: () => _handleLogout(context),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    children: [
                      Text('이름 변경은 관리자에게 문의하세요. (그 외 문의도 받음)'),
                      Text('Contact : firef0822@gmail.com')
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    final size = MediaQuery.of(context).size;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      leading: Icon(
        icon,
        color: customBlue,
        size: size.width * 0.06,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: size.width * 0.04,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: size.width * 0.06,
      ),
      onTap: onTap,
    );
  }
}
