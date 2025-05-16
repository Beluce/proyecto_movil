import 'package:http/http.dart' as http;

Future<void> authenticateTuya() async {
  final response = await http.post(
    Uri.parse('https://openapi.tuyaeu.com/v1.0/token?grant_type=1'),
    headers: {
      'client_id': 'ftaykcsq5ujpxpxh8998',
      'sign': 'FIRMA_GENERADA_SHA256',
      't': DateTime.now().millisecondsSinceEpoch.toString(),
      'sign_method': 'HMAC-SHA256',
    },
  );

  if (response.statusCode == 200) {
    print('Autenticado correctamente');
    print(response.body);
  } else {
    print('Error al autenticar: ${response.body}');
  }
}
