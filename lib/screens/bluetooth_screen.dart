import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;
  String connectionText = "Buscando dispositivo...";
  bool isConnecting = false;
  bool isConnected = false;

  void scanForDevices() {
    setState(() {
      isConnecting = true;
      connectionText = "Buscando dispositivo...";
    });

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == "HC-06") {
          setState(() {
            targetDevice = r.device;
            connectionText = "Dispositivo encontrado. Conectando...";
          });
          flutterBlue.stopScan();
          connectToDevice();
          break;
        }
      }
    });
  }

  void connectToDevice() async {
    if (targetDevice == null) return;

    try {
      await targetDevice!.connect();
      discoverServices();
    } catch (e) {
      setState(() {
        connectionText = "Error al conectar: $e";
        isConnecting = false;
      });
    }
  }

  void discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            targetCharacteristic = characteristic;
            connectionText = "Conectado a ${targetDevice!.name}";
            isConnected = true;
            isConnecting = false;
          });
          break;
        }
      }
    }
  }

  void sendCommand(String command) async {
    if (targetCharacteristic == null) return;

    try {
      await targetCharacteristic!.write(utf8.encode(command));
    } catch (e) {
      setState(() {
        connectionText = "Error al enviar comando: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control de Cerradura Bluetooth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isConnecting)
              CircularProgressIndicator(),
            Text(connectionText),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? null : scanForDevices,
              child: Text('Conectar a Dispositivo Bluetooth'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? () => sendCommand('O') : null,
              child: Text('Abrir Cerradura'),
            ),
            ElevatedButton(
              onPressed: isConnected ? () => sendCommand('C') : null,
              child: Text('Cerrar Cerradura'),
            ),
          ],
        ),
      ),
    );
  }
}
