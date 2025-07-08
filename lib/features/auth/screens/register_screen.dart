import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  String? _selectedGrade;
  String? _selectedClass;
  String? _selectedNumber;

  static const Color customBlue = Color(0xFF7B8CDE);
  static const Color customLightBlue = Color(0xFFE8EAFF); // 밝은 보라빛 하늘색

  final List<String> _grades = ['1학년', '2학년', '3학년'];
  final List<String> _classes = List.generate(9, (index) => '${index + 1}반');
  final List<String> _numbers = List.generate(30, (index) => '${index + 1}번');

  void _handleRegister() {
    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _selectedGrade == null ||
        _selectedClass == null ||
        _selectedNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 항목을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  InputDecoration _getDropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      isDense: true,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        // 드롭다운 버튼 스타일
        buttonTheme: ButtonTheme.of(context).copyWith(
          alignedDropdown: true,
        ),
        // 드롭다운 메뉴 스타일
        popupMenuTheme: PopupMenuThemeData(
          color: customLightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _getDropdownDecoration(label, icon),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        iconEnabledColor: customBlue,
        menuMaxHeight: 200,
        dropdownColor: customLightBlue,
        borderRadius: BorderRadius.circular(12),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
        // 드롭다운 메뉴 아이템 스타일
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((String item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48.0), // AppBar 높이 축소
        child: AppBar(
          title: const Text(
            '회원가입',
            style: TextStyle(fontSize: 18), // 타이틀 텍스트 크기 축소
          ),
          backgroundColor: customBlue,
          elevation: 0,
          centerTitle: true, // 타이틀 중앙 정렬
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '환영합니다!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: customBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '아래 정보를 입력하여 계정을 생성해주세요.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: '학년',
                        icon: Icons.school,
                        value: _selectedGrade,
                        items: _grades,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGrade = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdownField(
                        label: '반',
                        icon: Icons.class_,
                        value: _selectedClass,
                        items: _classes,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedClass = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdownField(
                        label: '번호',
                        icon: Icons.numbers,
                        value: _selectedNumber,
                        items: _numbers,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedNumber = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _handleRegister,
                  child: const Text(
                    '가입하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 