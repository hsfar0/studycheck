import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color customBlue = Color(0xFF2196F3);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // 로그아웃 후 로그인 화면으로 이동
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.06), // 6% of screen height
        child: AppBar(
          title: Text(
            '계정 관리',
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
          child: ListView(
            padding: EdgeInsets.all(size.width * 0.04), // 4% of screen width
            children: [
              _buildMenuItem(
                context,
                icon: Icons.person,
                title: '아이디 변경',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                icon: Icons.lock,
                title: '비밀번호 변경',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                icon: Icons.email,
                title: '이메일 변경',
                onTap: () {},
              ),
              const Divider(height: 1),
              SizedBox(height: size.height * 0.03), // 3% of screen height
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04, // 4% of screen width
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(
                      double.infinity,
                      size.height * 0.06, // 6% of screen height
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.02), // 2% of screen width
                    ),
                  ),
                  onPressed: () => _handleLogout(context),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.04, // 4% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
        horizontal: size.width * 0.04, // 4% of screen width
        vertical: size.height * 0.01, // 1% of screen height
      ),
      leading: Icon(
        icon,
        color: customBlue,
        size: size.width * 0.06, // 6% of screen width
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: size.width * 0.04, // 4% of screen width
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: size.width * 0.06, // 6% of screen width
      ),
      onTap: onTap,
    );
  }
} 