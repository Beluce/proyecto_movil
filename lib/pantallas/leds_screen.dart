import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:proyecto/componentes/boton_casco.dart';
import '../componentes/action_button.dart';
import '../services/BluetoothService.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final _bluetooth = FlutterBluetoothSerial.instance;
  //final bluetoothService = BluetoothService(); // prueba con persistencia de datos
  bool _bluetoothState = false;
  bool _isConnecting = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  int times = 0;

  void showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/gif/loadingDaftPunk.gif',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Cargando...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: GoogleFonts.orbitron().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void exitCircle() {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  void _receiveData() {
    _connection?.input?.listen((event) {
      if (String.fromCharCodes(event) == "p") {
        setState(() => times = times + 1);
      }
    });
  }

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
  }

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  @override
  void dispose() {
    if (_connection != null && _connection!.isConnected) {
      _connection!.finish(); // Sin await
      print('Bluetooth desconectado automáticamente');
      exitCircle();
    }
    super.dispose();
  }


  @override
  void initState() {
    super.initState();

    _requestPermission();

    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });

    _bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.STATE_OFF:
          setState(() => _bluetoothState = false);
          break;
        case BluetoothState.STATE_ON:
          setState(() => _bluetoothState = true);
          break;
        // case BluetoothState.STATE_TURNING_OFF:
        //   break;
        // case BluetoothState.STATE_TURNING_ON:
        //   break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Casco ❤️ GuyManuel'),
      ),
      body: Column(
        children: [_infoDevice(), Expanded(child: _listDevices()), _buttons()],
      ),
    );
  }

  //unused
  Widget _controlBT() {
    return SwitchListTile(
      value: _bluetoothState,
      onChanged: (bool value) async {
        if (value) {
          await _bluetooth.requestEnable();
        } else {
          await _bluetooth.requestDisable();
        }
      },
      tileColor: Colors.black26,
      title: Text(
        _bluetoothState ? "Bluetooth encendido" : "Bluetooth apagado",
      ),
    );
  }
  Widget _inputSerial() {
    //recibe senial de pulsador fisico
    return ListTile(
      trailing: TextButton(
        child: const Text('reiniciar'),
        onPressed: () => setState(() => times = 0),
      ),
      title: Padding(padding: const EdgeInsets.symmetric(vertical: 16.0)),
    );
  }
  //unused

  Widget _infoDevice() {
    return ListTile(
      leading: const Icon(
        Icons.bluetooth_searching_sharp,
        color: Colors.blueGrey,
      ),
      tileColor: Colors.white,
      title: Text(
        "Conectado a: ${_deviceConnected?.name ?? "Ninguno"}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing:
          _connection?.isConnected ?? false
              ? ElevatedButton.icon(
                onPressed: () async {
                  await _connection?.finish();
                  setState(() => _deviceConnected = null);
                },
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text("Desconectar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
              : ElevatedButton.icon(
                onPressed: () async {
                  if (!_bluetoothState) {
                    bool? enabled = await _bluetooth.requestEnable();
                    if (enabled != true) return;
                  }
                  _getDevices();
                },
                icon: const Icon(Icons.arrow_downward, size: 16),
                label: const Text("Ver dispositivos"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade100,
                  foregroundColor: Colors.blueGrey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
    );
  }

  Widget _listDevices() {
    return _isConnecting
        ? const Center()
        : SingleChildScrollView(
          child: Container(
            //color: const Color(0xFF0A0A0A),
            padding: const EdgeInsets.all(16),
            child: Column(
              children:
                  _devices.map((device) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.bluetooth_connected,
                          color: Colors.grey,
                          size: 28,
                        ),
                        title: Text(
                          device.name?.isNotEmpty == true
                              ? device.name!
                              : device.address,
                          style: const TextStyle(
                            //color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          device.address,
                          style: TextStyle(
                            //color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text(
                            "Conectarse",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.cyan.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            setState(() => _isConnecting = true);
                            showLoading(); // Muestra el gif personalizado

                            try {
                              _connection = await BluetoothConnection.toAddress(device.address);

                              _deviceConnected = device;
                              _devices = [];
                              _receiveData();

                              exitCircle();
                              showMsg("Conectado a ${device.name}", Colors.green);

                            } catch (e) {
                              exitCircle();
                              showMsg("No se pudo conectar al dispositivo", Colors.red);
                              debugPrint("Error al conectar: $e");
                            } finally {
                              setState(() => _isConnecting = false);
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
  }

  Widget _buttons() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0f7fa), Color(0xFFf1f8e9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Center(
          child: Text(
            'Controles por Zona',
            style: TextStyle(
              fontFamily: GoogleFonts.orbitron().fontFamily,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        children: [
          SizedBox(
            height: 350,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildCategory("Lateral", {
                    'ON': {
                      'code': 'N',
                      'img': 'assets/img/botones_casco/LateralON.png',
                    },
                    'OFF': {
                      'code': 'O',
                      'img': 'assets/img/botones_casco/LateralOFF.png',
                    },
                    'Cascada': {
                      'code': 'M',
                      'img': 'assets/img/botones_casco/LateralCascada.png',
                    },
                    'Ciclo Lento': {
                      'code': 'P',
                      'img': 'assets/img/botones_casco/LateralCicloLento.png',
                    },
                    'Ciclo Rapido': {
                      'code': 'Q',
                      'img': 'assets/img/botones_casco/LateralCicloRapido.png',
                    },
                  }),
                  _buildCategory("Cachetes Bajos", {
                    'ON': {
                      'code': 'F',
                      'img': 'assets/img/botones_casco/CDON.png',
                    },
                    'OFF': {
                      'code': 'G',
                      'img': 'assets/img/botones_casco/CDOFF.png',
                    },
                    'Ciclo Rapido': {
                      'code': 'A',
                      'img': 'assets/img/botones_casco/CDCicloRapido.png',
                    },
                    'Parpadeo Aleatorio': {
                      'code': 'B',
                      'img': 'assets/img/botones_casco/CDAleatorio.png',
                    },
                    'Ciclo Lento': {
                      'code': 'C',
                      'img': 'assets/img/botones_casco/CDCicloLento.png',
                    },
                    'Ida y Vuelta': {
                      'code': 'D',
                      'img': 'assets/img/botones_casco/CDIdaVuelta.png',
                    },
                    'Ciclo Rapido Parpadeo': {
                      'code': 'E',
                      'img': 'assets/img/botones_casco/CDAleatorioRapido.png',
                    },
                  }),
                  _buildCategory("Oreja", {
                    'ON': {
                      'code': 'H',
                      'img': 'assets/img/botones_casco/orejasON.png',
                    },
                    'OFF': {
                      'code': 'I',
                      'img': 'assets/img/botones_casco/orejasOFF.png',
                    },
                  }),
                  _buildCategory("Cachetes Arriba", {
                    'ON': {
                      'code': 'J',
                      'img': 'assets/img/botones_casco/CUPON.png',
                    },
                    'OFF': {
                      'code': 'K',
                      'img': 'assets/img/botones_casco/CUPOFF.png',
                    },
                    'Ida y Vuelta': {
                      'code': 'L',
                      'img': 'assets/img/botones_casco/CUPIdaVuelta.png',
                    },
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    String label,
    Map<String, Map<String, String>> actions,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                actions.entries.map((entry) {
                  final name = entry.key;
                  final data = entry.value;
                  return SizedBox(
                    width: 90,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 90,
                          child: AnimatedButton(
                            image: data['img']!,
                            label: name,
                            onTap: () => _sendData(data['code']!),
                          ),
                        ),
                      ],

                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}