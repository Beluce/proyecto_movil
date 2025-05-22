import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ControlFrontalScreen extends StatefulWidget {
  const ControlFrontalScreen({super.key});

  @override
  State<ControlFrontalScreen> createState() => _ControlFrontalScreenState();
}

class _ControlFrontalScreenState extends State<ControlFrontalScreen> {
  final int rows = 32;
  final int cols = 16;
  String ip = "192.168.20.107"; // ip comun con la que trabajo al arrancar el esp32
  final TextEditingController _ipController = TextEditingController();
  Color selectedColor = Colors.cyan;
  List<List<bool>> ledState = List.generate(32, (_) => List.filled(16, false)); // 32 rows, 16 cols

  @override
  void initState() {
    super.initState();
    _ipController.text = ip;
  }

  Future<void> _turnOff() async {
    final uri = Uri.parse(
      "http://$ip/clear",
    );
    try {
      await http.get(uri);
    } catch (e) {
      debugPrint("Error enviando comando: $e");
    }

    setState(() {
      ledState = List.generate(rows, (_) => List.filled(cols, false));
    });
  }

  Future<void> _sendPixel(int x, int y, bool state, {Color? colorOverride}) async {
    final color = colorOverride ?? selectedColor;
    final uri = Uri.parse(
      "http://$ip/set?x=$x&y=$y&r=${color.red}&g=${color.green}&b=${color.blue}&state=${state ? "on" : "off"}",
    );
    try {
      await http.get(uri);
    } catch (e) {
      debugPrint("Error enviando comando: $e");
    }
  }


  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return;

    final resized = img.copyResize(image, width: cols, height: rows);

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final pixel = resized.getPixelSafe(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        await _sendPixel(x, y, true, colorOverride: Color.fromARGB(255, r, g, b));
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control Matriz 16x32")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("IP ESP32:"),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ej: 192.168.1.123",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ip = _ipController.text.trim();
                    });
                  },
                  child: const Text("Aplicar"),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Color: "),
                GestureDetector(
                  onTap: () async {
                    Color? picked = await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (c) => Navigator.pop(ctx, c),
                          ),
                        ),
                      ),
                    );
                    if (picked != null) {
                      setState(() => selectedColor = picked);
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickAndSendImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Cargar imagen"),
                ),
                ElevatedButton.icon(
                  onPressed: _turnOff,
                  icon: const Icon(Icons.clear),
                  label: const Text("Limpiar matriz"),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                    ),
                    itemCount: rows * cols, // 512
                    itemBuilder: (context, index) {
                      final x = index % cols; // columna
                      final y = index ~/ cols; // fila
                      final isOn = ledState[y][x]; // fila y, columna x
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            ledState[y][x] = !isOn;
                          });
                          _sendPixel(x, y, !isOn);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isOn ? selectedColor : Colors.black,
                            border: Border.all(width: 0.3, color: Colors.grey.shade800),
                          ),
                        ),
                      );
                    },
                  );

                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}