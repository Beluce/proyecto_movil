import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImgurUploader {
  static const String clientId = '1d137012ca4b73f';

  static Future<String> uploadImage(Uint8List imageBytes) async {
    final Uri uri = Uri.parse('https://api.imgur.com/3/image');
    final String base64Image = base64Encode(imageBytes);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Client-ID $clientId',
      },
      body: {
        'image': base64Image,
        'type': 'base64',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['data']['link'];
    } else {
      print('Error: ${response.body}');
      throw Exception('Error al subir la imagen a Imgur');
    }
  }
}
