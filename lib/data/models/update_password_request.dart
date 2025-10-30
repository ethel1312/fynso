class UpdatePasswordRequest {
  final String email;
  final String newPassword;

  UpdatePasswordRequest({required this.email, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'new_password': newPassword,
    };
  }
}
