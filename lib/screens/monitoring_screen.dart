import 'package:flutter/material.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  final List<String> logs = const [
    "Usuario 1 - RFID - 12:00 PM",
    "Usuario 2 - Bluetooth - 12:05 PM",
    // Lista de registros simulada
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitorización')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(logs[index]),
                leading: Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}