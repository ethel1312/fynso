class SendCodeRequest {
  final String email;

  SendCodeRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
