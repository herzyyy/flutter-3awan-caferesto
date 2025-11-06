import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/caferesto_model.dart';

class ApiService {
  static const String baseUrl = "http://192.168.100.112:5000/api"; // emulator Android

  static Future<List<Menu>> fetchMenus() async {
    final response = await http.get(Uri.parse('$baseUrl/menus'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => Menu.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data menu');
    }
  }
}
