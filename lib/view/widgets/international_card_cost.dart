import 'package:flutter/material.dart';
import '../../model/international_cost.dart';

class CardInternationalCost extends StatelessWidget {
  final InternationalCost cost;
  const CardInternationalCost(this.cost, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Icon(Icons.flight, color: Colors.blue[800])),
        title: Text('${cost.name} - ${cost.service}', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Biaya: ${cost.currency} ${cost.cost}'),
          Text('Estimasi: ${cost.etd}'),
        ]),
      ),
    );
  }
}
