import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  final List<String> alerts = const [
    "Alerta 1 - Intento fallido de acceso",
    "Alerta 2 - Usuario desconocido",
    // Lista de alertas simulada
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de Seguridad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(alerts[index]),
                leading: Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.error,
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Implementar lógica para resolver alerta
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Resolver'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}