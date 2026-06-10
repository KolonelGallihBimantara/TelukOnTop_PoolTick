import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const headers = {
    'Content-Type': 'application/json',
    'x-api-key': 'kolamrenang2026',
  };

  static Future<List<dynamic>> getTickets() async {
    final res = await http.get(
      Uri.parse('http://localhost:3000/tickets'),
      headers: headers,
    );

    return json.decode(res.body);
  }

  static Future<bool> beliTiket(int id, String name) async {
    final res = await http.post(
      Uri.parse('http://localhost:3000/transactions'),
      headers: headers,
      body: jsonEncode({
        'ticketId': id,
        'name': name,
      }),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }
}