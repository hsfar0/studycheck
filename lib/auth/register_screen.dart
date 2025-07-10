import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Added for FilteringTextInputFormatter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // 텍스트 필드 표시용 컨트롤러
  final _displayGradeController = TextEditingController();
  final _displayClassController = TextEditingController();
  final _displayNumberController = TextEditingController();

  // Firestore 저장용 변수
  String? _selectedGrade;
  String? _selectedClass;
  String? _selectedNumber;
  String? _year;

  static const Color customBlue = Color(0xFF7B8CDE);
  static const Color customLightBlue = Color(0xFFE8EAFF); // 밝은 보라빛 하늘색
  static const String emailDomain = '@gyeongsin.hs.kr';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateDisplayFields);
  }

  void _updateDisplayFields() {
    String email = _emailController.text;
    if (email.startsWith('gs')) {
      try {
        // gs 이후의 모든 문자열 가져오기
        String numbers = email.substring(2);
        // 숫자만 추출
        numbers = numbers.replaceAll(RegExp(r'[^0-9]'), '');

        if (numbers.isNotEmpty) {
          // year는 처음 2자리
          int currentIndex = 2;  // year(2자리) 이후부터 시작

          // 학년 파싱 (1자리)
          if (currentIndex < numbers.length) {
            String grade = numbers[currentIndex];
            // 학년 유효성 검사 (1,2,3)
            if (['1', '2', '3'].contains(grade)) {
              _displayGradeController.text = '$grade학년';
            } else {
              _displayGradeController.text = '';
            }
            currentIndex++;
          } else {
            _displayGradeController.text = '';
          }

          // 반 파싱 (1자리)
          if (currentIndex < numbers.length) {
            String classNum = numbers[currentIndex];
            // 반 유효성 검사 (1-9)
            int classNumInt = int.tryParse(classNum) ?? 0;
            if (classNumInt >= 1 && classNumInt <= 9) {
              _displayClassController.text = '$classNumInt반';
            } else {
              _displayClassController.text = '';
            }
            currentIndex++;
          } else {
            _displayClassController.text = '';
          }

          // 번호 파싱 (최대 2자리)
          if (currentIndex < numbers.length) {
            String number = numbers.substring(currentIndex);
            if (number.length > 2) {
              number = number.substring(0, 2);
            }
            // 번호 유효성 검사 및 형식 변환 (1-30)
            int numberInt = int.tryParse(number) ?? 0;
            // 번호가 두 자리이고 1-30 범위 내일 때만 표시
            if (number.length == 2 && numberInt >= 1 && numberInt <= 30) {
              _displayNumberController.text = '$numberInt번';
            } else {
              _displayNumberController.text = '';
            }
          } else {
            _displayNumberController.text = '';
          }
        } else {
          _displayGradeController.text = '';
          _displayClassController.text = '';
          _displayNumberController.text = '';
        }
      } catch (e) {
        // 파싱 오류 시 아무것도 하지 않음
      }
    } else {
      setState(() {
        _displayGradeController.text = '';
        _displayClassController.text = '';
        _displayNumberController.text = '';
      });
    }
  }

  // 이메일 형식 검증 및 파싱 함수
  bool _parseStudentInfo(String email) {
    // gs로 시작하는지 확인
    if (!email.startsWith('gs')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일은 gs로 시작해야 합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // gs 이후의 모든 문자열 가져오기
    String numbers = email.substring(2);
    // 숫자만 추출
    numbers = numbers.replaceAll(RegExp(r'[^0-9]'), '');

    // 숫자가 있는지 확인
    if (numbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('gs 이후에는 숫자를 입력해야 합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // 최소 3자리 숫자가 필요 (year 2자리 + 학년 1자리)
    if (numbers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 3자리 이상의 숫자가 필요합니다. (예: gs251)'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // 순서대로 정보 파싱
    // year는 처음 2자리
    _year = numbers.substring(0, 2);
    int currentIndex = 2;

    // 학년 파싱 및 검증 (1자리)
    String grade = numbers[currentIndex];
    if (!['1', '2', '3'].contains(grade)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('학년은 1, 2, 3 중 하나여야 합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    _selectedGrade = grade;
    currentIndex++;

    // 반 파싱 및 검증 (1자리)
    if (currentIndex < numbers.length) {
      String classNum = numbers[currentIndex];
      int classNumInt = int.tryParse(classNum) ?? 0;
      if (classNumInt < 1 || classNumInt > 9) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('반은 1부터 9까지의 숫자여야 합니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      _selectedClass = classNumInt.toString();
      currentIndex++;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반 정보가 필요합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // 번호 파싱 및 검증 (최대 2자리)
    if (currentIndex < numbers.length) {
      String number = numbers.substring(currentIndex);
      if (number.length > 2) {
        number = number.substring(0, 2);
      }
      int numberInt = int.tryParse(number) ?? 0;

      // 번호 유효성 검사 (1-30)
      if (numberInt < 1 || numberInt > 30) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('번호는 1부터 30까지의 숫자여야 합니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      _selectedNumber = numberInt.toString();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('번호 정보가 필요합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _handleRegister() async {
    try {
      // 입력값 검증
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 항목을 입력해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 이름 유효성 검사
      String name = _nameController.text;
      if (name.length < 2 || name.length > 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이름은 2~4글자의 한글로 입력해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }


      // 한글 유효성 검사
      if (!RegExp(r'^[가-힣]{2,4}$').hasMatch(name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이름은 한글만 입력 가능합니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 이메일 형식 검증 및 파싱
      if (!_parseStudentInfo(_emailController.text)) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text + emailDomain;

        // Firebase Auth로 사용자 생성
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );


        // Firestore에 저장할 사용자 데이터
        final userData = {
          'email': email,
          'name': _nameController.text,
          'year': int.parse(_year!),
          'grade': int.parse(_selectedGrade!),
          'class': int.parse(_selectedClass!),
          'number': int.parse(_selectedNumber!),
          'createdAt': FieldValue.serverTimestamp(),
          'isStudying': false,
          'studyDay': 0,
          'studyNight': 0,
          'studyTime': 0
        };

        // Firestore에 사용자 추가 정보 저장
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        if (mounted) {
          // 회원가입 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );

          // 홈 화면으로 이동
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        String message = '회원가입 중 오류가 발생했습니다.';

        if (e.code == 'weak-password') {
          message = '비밀번호가 너무 약합니다. (최소 6자 이상)';
        } else if (e.code == 'email-already-in-use') {
          message = '이미 사용 중인 이메일입니다.';
        } else if (e.code == 'invalid-email') {
          message = '유효하지 않은 이메일 형식입니다.';
        } else if (e.code == 'operation-not-allowed') {
          message = '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예기치 않은 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateDisplayFields);
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _displayGradeController.dispose();
    _displayClassController.dispose();
    _displayNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: AppBar(
          title: const Text(
            '회원가입',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: customBlue,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      body: Stack(
        children: [
          Container(
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
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: '이메일',
                            prefixIcon: Icon(Icons.email),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
                          ],
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Text(
                            emailDomain,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        hintText: '6자 이상',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4F4F4F)
                        ),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '이름(실명)',
                        prefixIcon: Icon(Icons.badge),
                        hintText: '한글 2~4글자',
                        hintStyle: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4F4F4F)
                        ),
                      ),
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _displayGradeController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: '학년',
                              hintText: '학년',
                              prefixIcon: Icon(Icons.school),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _displayClassController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: '반',
                              hintText: '반',
                              prefixIcon: Icon(Icons.class_),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _displayNumberController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: '번호',
                              hintText: '번호',
                              prefixIcon: Icon(Icons.numbers),
                            ),
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
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}