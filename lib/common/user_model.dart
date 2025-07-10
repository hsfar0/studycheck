class UserModel {
  final String id;
  final String email;
  final String username;
  final String name;
  final int grade;
  final int classNumber;
  final int studentNumber;
  final int totalStudyTime;
  final int lateCount;
  final int nightStudyCount;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.grade,
    required this.classNumber,
    required this.studentNumber,
    this.totalStudyTime = 0,
    this.lateCount = 0,
    this.nightStudyCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'grade': grade,
      'classNumber': classNumber,
      'studentNumber': studentNumber,
      'totalStudyTime': totalStudyTime,
      'lateCount': lateCount,
      'nightStudyCount': nightStudyCount,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      name: map['name'],
      grade: map['grade'],
      classNumber: map['classNumber'],
      studentNumber: map['studentNumber'],
      totalStudyTime: map['totalStudyTime'] ?? 0,
      lateCount: map['lateCount'] ?? 0,
      nightStudyCount: map['nightStudyCount'] ?? 0,
    );
  }
} 