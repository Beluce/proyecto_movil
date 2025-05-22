import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? connection;
  BluetoothDevice? deviceConnected;

  Future<void> connectTo(BluetoothDevice device) async {
    connection = await BluetoothConnection.toAddress(device.address);
    deviceConnected = device;
  }

  void sendData(String data) {
    if (connection?.isConnected ?? false) {
      connection?.output.add(ascii.encode(data));
    }
  }

  void closeConnection() {
    connection?.finish();
    deviceConnected = null;
  }
}
