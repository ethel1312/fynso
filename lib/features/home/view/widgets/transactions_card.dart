import 'package:flutter/material.dart';

class TransactionsCard extends StatelessWidget {
  const TransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        "title": "Café Starbucks",
        "category": "Comida",
        "date": "Hoy",
        "amount": -8.75,
      },
      {
        "title": "Viaje en Uber",
        "category": "Transporte",
        "date": "Hoy",
        "amount": -22.5,
      },
      {
        "title": "Supermercado",
        "category": "Comida",
        "date": "Ayer",
        "amount": -156.8,
      },
      {
        "title": "Spotify",
        "category": "Servicios",
        "date": "Ayer",
        "amount": -9.99,
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transacciones Recientes",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text("Ver Todo")),
              ],
            ),
            const SizedBox(height: 8),
            ...transactions.map(
              (tx) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx["title"].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tx["category"].toString(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          tx["date"].toString(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          "\S/.${tx["amount"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
