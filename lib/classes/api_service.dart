import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://131.0.245.253:3030";

  Future<String?> iniciarSessaoWhatsapp(String emailUser) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/whatsapp'),
        headers: {"Content-Type": "application/json", "x-api-key": "4202@back"},
        body: jsonEncode({'email_user': emailUser}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['qrCode'] != null) {
          return data['qrCode'];
        } else {
          print('QR Code não retornado');
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao criar sessão: $error');
    }
    return null;
  }

  Future<Map<String, dynamic>> verificarStatusWhatsApp(String emailUser) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/whatsapp/status'),
        headers: {"Content-Type": "application/json", "x-api-key": "4202@back"},
        body: jsonEncode({'email_user': emailUser}),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Erro ao verificar o status do WhatsApp: $e');
      return {'error': 'Erro ao verificar o status do WhatsApp'};
    }
  }

  Future<Map<String, dynamic>> cancelarAssinatura(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cancelar-assinatura'),
        headers: {"Content-Type": "application/json", "x-api-key": "4202@back"},
        body: jsonEncode({"id": id}),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> criarPlano(
      String name, int repeats, int interval) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/criar-plano'),
        headers: {"Content-Type": "application/json", "x-api-key": "4202@back"},
        body: jsonEncode({'name': name, 'repeats': null, 'interval': interval}),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Erro ao criar o plano: $e');
      return {'error': 'Erro ao criar o plano'};
    }
  }

  Future<Map<String, dynamic>> deletarPlano(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/deletar-plano'),
        headers: {"Content-Type": "application/json", "x-api-key": "4202@back"},
        body: jsonEncode({"id": id}),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      return {"error": e.toString()};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      return {
        'body': json.decode(response.body),
        'status': response.statusCode
      };
    } else {
      return {
        "error": json.decode(response.body)["error"] ?? "Falha desconhecida",
        "status": response.statusCode
      };
    }
  }
}
