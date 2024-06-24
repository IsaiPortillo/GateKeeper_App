import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gatekeeper/services/firebase_services.dart';
import 'package:web_socket_channel/io.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({Key? key}) : super(key: key);

  @override
  _MonitorScreenState createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  late IOWebSocketChannel channel;
  Uint8List? imageBytes;
  final List<Uint8List> _buffer = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://192.168.32.211:8888');
    channel.stream.listen((message) {
      _buffer.add(Uint8List.fromList(message));
      if (_buffer.length > 5) {
        _buffer.removeAt(0);
      }
    });

    // Setup a timer to update the image at 25 FPS
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_buffer.isNotEmpty) {
        setState(() {
          imageBytes = _buffer.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: imageBytes != null
                    ? Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                )
                    : const Center(child: CircularProgressIndicator()),
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
