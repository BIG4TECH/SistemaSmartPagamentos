import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl = "https://4bda-131-0-245-253.ngrok-free.app";
  final Dio dio = Dio();

  Future<String?> iniciarSessaoWhatsapp(String emailUser) async {
    try {
      final response = await dio.post(
        '$baseUrl/whatsapp',
        options: Options(headers: {
          "Content-Type": "application/json",
          "x-api-key": "4202@back",
          "ngrok-skip-browser-warning": true
        }),
        data: {'email_user': emailUser},
      );

      if (response.statusCode == 200) {
        final data = response.data;
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
      final response = await dio.get(
        '$baseUrl/whatsapp/status',
        queryParameters: {'email_user': emailUser},
        options: Options(headers: {
          "Content-Type": "application/json",
          "x-api-key": "4202@back",
          "ngrok-skip-browser-warning": true
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Erro ao verificar o status do WhatsApp: $e');
      return {'error': 'Erro ao verificar o status do WhatsApp'};
    }
  }

  Future<Map<String, dynamic>> cancelarAssinatura(int id) async {
    try {
      final response = await dio.post(
        '$baseUrl/cancelar-assinatura',
        options: Options(headers: {
          "Content-Type": "application/json",
          "x-api-key": "4202@back",
          "ngrok-skip-browser-warning": true
        }),
        data: {"id": id},
      );

      return _handleResponse(response);
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> criarPlano(
      String name, String recurrencePeriod) async {
    try {
      final response = await dio.post(
        '$baseUrl/criar-plano',
        options: Options(headers: {
          "Content-Type": "application/json",
          "x-api-key": "4202@back",
          "ngrok-skip-browser-warning": true
        }),
        data: {'name': name, 'recurrencePeriod': recurrencePeriod},
      );
      return _handleResponse(response);
    } catch (e) {
      print('Erro ao criar o plano: $e');
      return {'error': 'Erro ao criar o plano'};
    }
  }

  Future<Map<String, dynamic>> deletarPlano(int id) async {
    try {
      final response = await dio.post(
        '$baseUrl/deletar-plano',
        options: Options(headers: {
          "Content-Type": "application/json",
          "x-api-key": "4202@back",
          "ngrok-skip-browser-warning": true
        }),
        data: {"id": id},
      );

      return _handleResponse(response);
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      return {"error": e.toString()};
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode! > 199 && response.statusCode! < 300) {
      print(response.data);
      return {
        'body': response.data,
        'status': response.statusCode,
      };
    } else {
      return {
        "error": response.data["error"] ?? "Falha desconhecida",
        "status": response.statusCode,
      };
    }
  }
}
