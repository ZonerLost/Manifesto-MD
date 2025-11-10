class AuthModel {
  final String uid;
  final String email;
  final String? name;
  final String? country;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;


  AuthModel({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.country,
    this.fcmToken,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'country' : country,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      country: map['country'],
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  AuthModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? country,
    String? photoUrl,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return AuthModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      country: country ?? this.country,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AuthModel('
        'uid: $uid, '
        'email: $email, '
        'name: $name, '
        'country: $country ' 
        'photoUrl: $photoUrl, '
        'fcmToken: $fcmToken, '
        'createdAt: $createdAt'
        ')';
  }
}


