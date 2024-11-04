import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:3000";

  Future<String?> iniciarSessaoWhatsapp() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/whatsapp'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['qrCode'] != null) {
          return data['qrCode']; // Retorna o QR Code em base64
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

  Future<Map<String, dynamic>> cancelarAssinatura(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cancelar-assinatura'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> verificarEstadoWhatsapp() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/whatsapp-status'));
      return _handleResponse(response);
    } catch (e) {
      print('Erro ao verificar o estado do WhatsApp: $e');
      return {'error': 'Erro ao verificar o estado'};
    }
  }

  Future<Map<String, dynamic>> criarPlano(
      String name, int repeats, int interval) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/criar-plano'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'name': name, 'repeats': repeats, 'interval': interval}),
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
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}), 
    );

    return _handleResponse(response);
  } catch (e) {
    print('Erro ao fazer requisição: $e');
    return {"error": e.toString()};
  }
}


  Future<Map<String, dynamic>> listarPlanos({String? name}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/listar-planos'),
        headers: {"Content-Type": "application/json"},
        body: name != null ? jsonEncode({'name': name}) : jsonEncode({}),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Erro ao listar planos: $e');
      return {'error': 'Erro ao listar planos'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
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
