import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothControlScreenState createState() => _BluetoothControlScreenState();
}

class _BluetoothControlScreenState extends State<BluetoothScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice? _device;
  BluetoothConnection? _connection;
  String _connectionStatus = 'No conectado';

  @override
  void initState() {
    super.initState();
    // Obtener el estado actual del Bluetooth
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Escuchar cambios en el estado del Bluetooth
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  Future<void> _connectToDevice() async {
    setState(() {
      _connectionStatus = 'Conectando...';
    });

    // Mostrar una ventana de diálogo para seleccionar un dispositivo emparejado
    BluetoothDevice? selectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Dispositivo Bluetooth'),
          content: FutureBuilder<List<BluetoothDevice>>(
            future: FlutterBluetoothSerial.instance.getBondedDevices(),
            builder: (BuildContext context, AsyncSnapshot<List<BluetoothDevice>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay dispositivos emparejados'));
              } else {
                return ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.map((device) {
                    return ListTile(
                      title: Text(device.name ?? 'Dispositivo sin nombre'),
                      subtitle: Text(device.address),
                      onTap: () {
                        Navigator.of(context).pop(device);
                      },
                    );
                  }).toList(),
                );
              }
            },
          ),
        );
      },
    );

    // Conectar al dispositivo seleccionado
    if (selectedDevice != null) {
      try {
        _device = selectedDevice;
        _connection = await BluetoothConnection.toAddress(_device!.address);
        setState(() {
          _connectionStatus = 'Conectado a ${_device!.name}';
        });
      } catch (e) {
        setState(() {
          _connectionStatus = 'Error al conectar: $e';
        });
      }
    } else {
      setState(() {
        _connectionStatus = 'No se seleccionó ningún dispositivo';
      });
    }
  }

  void _sendCommand(int angle) {
    if (_connection != null && _connection!.isConnected) {
      try {
        _connection!.output.add(utf8.encode('$angle\n')); // Ensure angle is followed by newline
        _connection!.output.allSent.then((_) {
          setState(() {
            _connectionStatus = 'Comando enviado: $angle';
          });
        });
      } catch (e) {
        setState(() {
          _connectionStatus = 'Error al enviar comando: $e';
        });
      }
    } else {
      setState(() {
        _connectionStatus = 'No hay conexión activa';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control de Servo vía Bluetooth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Estado de la conexión: $_connectionStatus'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connection != null && _connection!.isConnected ? null : () => _connectToDevice(),
              child: Text('Conectar a Dispositivo Bluetooth'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connection != null && _connection!.isConnected ? () => _sendCommand(0) : null,
              child: Text('Mover Servo a 0 grados'),
            ),
            ElevatedButton(
              onPressed: _connection != null && _connection!.isConnected ? () => _sendCommand(90) : null,
              child: Text('Mover Servo a 90 grados'),
            ),
            ElevatedButton(
              onPressed: _connection != null && _connection!.isConnected ? () => _sendCommand(180) : null,
              child: Text('Mover Servo a 180 grados'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cerrar la conexión al eliminar el widget
    _connection?.finish();
    super.dispose();
  }
}
