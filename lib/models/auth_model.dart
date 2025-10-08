class AuthModel {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;

  AuthModel({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'AuthModel('
        'uid: $uid, '
        'email: $email, '
        'name: $name, '
        'photoUrl: $photoUrl, '
        'createdAt: $createdAt'
        ')';
  }
}