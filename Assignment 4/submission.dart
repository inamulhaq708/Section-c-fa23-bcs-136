class Submission {
  final int? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime? createdAt;

  Submission({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    this.createdAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      gender: json['gender'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
    };
  }

  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
    };
  }
}