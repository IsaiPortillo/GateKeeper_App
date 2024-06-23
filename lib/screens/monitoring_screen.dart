import 'package:flutter/material.dart';
import 'package:gatekeeper/services/firebase_services.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // URL de la transmisión en tiempo real de la ESP32-CAM
    final String cameraStreamUrl = 'http://192.168.32.222';

    return Scaffold(
      appBar: AppBar(title: const Text('Monitorización')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Widget para mostrar la transmisión de la cámara
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              height: 200.0, // Altura ajustable de la transmisión de video
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // Borde negro alrededor del video
                borderRadius: BorderRadius.circular(16.0), // Bordes redondeados
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  cameraStreamUrl,
                  fit: BoxFit.cover, // Ajustar la imagen al contenedor
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('Error al cargar la transmisión de video'));
                  },
                ),
              ),
            ),
            // Card para mostrar las notificaciones
            Expanded(
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
                            margin: const EdgeInsets.all(8), // Margen alrededor de la ListTile
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black), // Borde negro
                              borderRadius: BorderRadius.circular(8), // Bordes redondeados
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(snapshot.data?[index]['Nombre']),
                                  const SizedBox(width: 8),
                                  Text('Sensor: ${snapshot.data?[index]['Sensor']}'),
                                  const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}
