import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

const baseUrl = 'http://172.19.0.125:8000'; // máy chạy backend

Future<String?> signInWithGoogle() async {
  final account = await GoogleSignIn.instance.authenticate();
  final idToken = account.authentication.idToken;
  if (idToken == null) return null;

  final res = await http.post(
    Uri.parse('$baseUrl/login/google'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'id_token': idToken}),
  );
  if (res.statusCode != 200) return null;
  print(jsonDecode(res.body)['access_token']);
  return jsonDecode(res.body)['access_token'] as String;
}
