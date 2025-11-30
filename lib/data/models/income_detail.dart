class IncomeDetail {
  final int idIncome;
  final double amount;
  final String date; // "yyyy-MM-dd"
  final String time; // "HH:mm"
  final String? notes;

  IncomeDetail({
    required this.idIncome,
    required this.amount,
    required this.date,
    required this.time,
    this.notes,
  });

  factory IncomeDetail.fromJson(Map<String, dynamic> json) {
    return IncomeDetail(
      idIncome: json['id_income'] as int,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['fecha'] as String,
      time: json['hora'] as String,
      notes: json['notes'] as String?,
    );
  }
}
