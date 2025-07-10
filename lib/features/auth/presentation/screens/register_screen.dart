import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auth_text_field.dart';
import '../../../../core/theme/app_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _classController = TextEditingController();
  final _numberController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _gradeController.dispose();
    _classController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    
    // gs로 시작하는지 확인
    if (!value.startsWith('gs')) {
      return '이메일은 gs로 시작해야 합니다';
    }
    
    // gs 다음에 오는 문자열이 숫자인지 확인
    final numberPart = value.substring(2);
    if (int.tryParse(numberPart) == null) {
      return 'gs 다음에는 숫자가 와야 합니다';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 다시 입력해주세요';
    }
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    
    // 한글만 허용하고 2~4자 제한
    final RegExp hangulRegExp = RegExp(r'^[가-힣]{2,4}$');
    if (!hangulRegExp.hasMatch(value)) {
      return '이름은 2~4자의 한글만 가능합니다';
    }
    
    return null;
  }

  String? _validateGrade(String? value) {
    if (value == null || value.isEmpty) {
      return '학년을 입력해주세요';
    }
    
    final grade = int.tryParse(value);
    if (grade == null || grade < 1 || grade > 3) {
      return '1~3 사이의 숫자를 입력해주세요';
    }
    
    return null;
  }

  String? _validateClass(String? value) {
    if (value == null || value.isEmpty) {
      return '반을 입력해주세요';
    }
    
    final classNum = int.tryParse(value);
    if (classNum == null || classNum < 1 || classNum > 9) {
      return '1~9 사이의 숫자를 입력해주세요';
    }
    
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '번호를 입력해주세요';
    }
    
    final number = int.tryParse(value);
    if (number == null || number < 1 || number > 30) {
      return '1~30 사이의 숫자를 입력해주세요';
    }
    
    return null;
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 이메일 생성
        final email = '${_emailController.text}@gyeongsin.hs.kr';
        
        // Firebase Authentication으로 사용자 생성
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );
        
        // Firestore에 사용자 정보 저장
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': _nameController.text,
          'grade': int.parse(_gradeController.text),
          'class': int.parse(_classController.text),
          'number': int.parse(_numberController.text),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          // 회원가입 성공 후 로그인 화면으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        
        switch (e.code) {
          case 'email-already-in-use':
            message = '이미 사용 중인 이메일입니다.';
            break;
          case 'invalid-email':
            message = '유효하지 않은 이메일 형식입니다.';
            break;
          case 'operation-not-allowed':
            message = '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
            break;
          case 'weak-password':
            message = '비밀번호가 너무 약합니다.';
            break;
          default:
            message = '회원가입 중 오류가 발생했습니다: ${e.message}';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('회원가입 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.06),
        child: AppBar(
          title: Text(
            '회원가입',
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
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(size.width * 0.04),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _emailController,
                        labelText: '이메일',
                        validator: _validateEmail,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Container(
                      padding: EdgeInsets.only(top: size.height * 0.015),
                      child: Text(
                        '@gyeongsin.hs.kr',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                AuthTextField(
                  controller: _passwordController,
                  labelText: '비밀번호',
                  validator: _validatePassword,
                  obscureText: !_isPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                AuthTextField(
                  controller: _confirmPasswordController,
                  labelText: '비밀번호 확인',
                  validator: _validateConfirmPassword,
                  obscureText: !_isConfirmPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                AuthTextField(
                  controller: _nameController,
                  labelText: '이름',
                  validator: _validateName,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[가-힣]')),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _gradeController,
                        labelText: '학년',
                        validator: _validateGrade,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: AuthTextField(
                        controller: _classController,
                        labelText: '반',
                        validator: _validateClass,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: AuthTextField(
                        controller: _numberController,
                        labelText: '번호',
                        validator: _validateNumber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: Size(
                      double.infinity,
                      size.height * 0.06,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.02),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? SizedBox(
                          height: size.width * 0.05,
                          width: size.width * 0.05,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '회원가입',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.04,
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