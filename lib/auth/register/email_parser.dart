import 'package:flutter/material.dart';

class EmailParser {
  final BuildContext context;
  String? year;
  String? grade;
  String? classNum;
  String? number;

  EmailParser(this.context);

  bool parse(String email) {
    if (!email.startsWith('gs')) {
      _showError('이메일은 gs로 시작해야 합니다.');
      return false;
    }

    String numbers = email.substring(2);
    numbers = numbers.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.isEmpty) {
      _showError('gs 이후에는 숫자를 입력해야 합니다.');
      return false;
    }

    if (numbers.length < 6) {
      _showError('존재하는 이메일을 입력해주세요 (예: gs251101)');
      return false;
    }

    year = numbers.substring(0, 2);
    int currentIndex = 2;

    String g = numbers[currentIndex];
    if (!['1', '2', '3'].contains(g)) {
      _showError('학년은 1, 2, 3 중 하나여야 합니다.');
      return false;
    }
    grade = g;
    currentIndex++;

    if (currentIndex < numbers.length) {
      String c = numbers[currentIndex];
      int cInt = int.tryParse(c) ?? 0;
      if (cInt < 1 || cInt > 9) {
        _showError('반은 1부터 9까지의 숫자여야 합니다.');
        return false;
      }
      classNum = c;
      currentIndex++;
    } else {
      _showError('반 정보가 필요합니다.');
      return false;
    }

    if (currentIndex < numbers.length) {
      String n = numbers.substring(currentIndex);
      if (n.length > 2) {
        n = n.substring(0, 2);
      }
      int nInt = int.tryParse(n) ?? 0;
      if (nInt < 1 || nInt > 30) {
        _showError('번호는 1부터 30까지의 숫자여야 합니다.');
        return false;
      }
      number = nInt.toString();
    } else {
      _showError('번호 정보가 필요합니다.');
      return false;
    }

    return true;
  }

  void fillDisplayFields(
      String email,
      TextEditingController gradeCtrl,
      TextEditingController classCtrl,
      TextEditingController numberCtrl,
      ) {
    if (!email.startsWith('gs')) {
      gradeCtrl.text = '';
      classCtrl.text = '';
      numberCtrl.text = '';
      return;
    }

    try {
      String numbers = email.substring(2);
      numbers = numbers.replaceAll(RegExp(r'[^0-9]'), '');

      if (numbers.isEmpty) {
        gradeCtrl.text = '';
        classCtrl.text = '';
        numberCtrl.text = '';
        return;
      }

      int index = 2;

      if (index < numbers.length) {
        String g = numbers[index];
        gradeCtrl.text = ['1', '2', '3'].contains(g) ? '$g학년' : '';
        index++;
      } else {
        gradeCtrl.text = '';
      }

      if (index < numbers.length) {
        String c = numbers[index];
        int cInt = int.tryParse(c) ?? 0;
        classCtrl.text = (cInt >= 1 && cInt <= 9) ? '$cInt반' : '';
        index++;
      } else {
        classCtrl.text = '';
      }

      if (index < numbers.length) {
        String n = numbers.substring(index);
        if (n.length > 2) n = n.substring(0, 2);
        int nInt = int.tryParse(n) ?? 0;
        numberCtrl.text = (n.length == 2 && nInt >= 1 && nInt <= 30) ? '$nInt번' : '';
      } else {
        numberCtrl.text = '';
      }
    } catch (_) {
      // 오류 무시
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
