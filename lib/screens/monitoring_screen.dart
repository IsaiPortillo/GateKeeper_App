import 'package:flutter/material.dart';
import 'package:gatekeeper/services/firebase_services.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({Key? key});

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
          child: FutureBuilder(
            future: getData(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    // Obtener la hora de la fecha
                    DateTime dateTime = snapshot.data?[index]['Hora'].toDate();
                    String hora = '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
                    // Usar un ListTile para mostrar Nombre, Sensor y Hora
                    return Container(
                      margin: EdgeInsets.all(8), // Margen alrededor de la ListTile
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // Borde negro
                        borderRadius: BorderRadius.circular(8), // Bordes redondeados
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(snapshot.data?[index]['Nombre']),
                            SizedBox(width: 8),
                            Text('Sensor: ${snapshot.data?[index]['Sensor']}'),
                            SizedBox(width: 8),
                            Text('Hora: $hora'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}
