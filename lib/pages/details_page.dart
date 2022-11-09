import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final Map rates;

  const DetailsPage({required this.rates});

  @override
  Widget build(BuildContext context) {
    List currencies = rates.keys.toList();
    List exchangeRates = rates.values.toList();
    return Scaffold(
        body: SafeArea(
      child: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (BuildContext context, int index) {
          String currency = currencies[index].toUpperCase();
          String exchangeRate = exchangeRates[index].toString();
          return ListTile(
            title: Text(
              "$currency: $exchangeRate",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    ));
  }
}
