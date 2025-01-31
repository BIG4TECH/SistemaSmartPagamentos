import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';

class ApiService {
  final Dio dio = Dio();

  Future<String?> iniciarSessaoWhatsapp(String emailUser) async {
    try {
      final String baseUrl = await FirebaseFirestore.instance
          .collection('link')
          .doc('link')
          .get()
          .then((value) => value['link']);

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
      final String baseUrl = await FirebaseFirestore.instance
          .collection('link')
          .doc('link')
          .get()
          .then((value) => value['link']);

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
      final String baseUrl = await FirebaseFirestore.instance
          .collection('link')
          .doc('link')
          .get()
          .then((value) => value['link']);

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
      final String baseUrl = await FirebaseFirestore.instance
          .collection('link')
          .doc('link')
          .get()
          .then((value) => value['link']);

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
      final String baseUrl = await FirebaseFirestore.instance
          .collection('link')
          .doc('link')
          .get()
          .then((value) => value['link']);

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

  Future<Map<String, dynamic>> getMensagensPendentes(String afiliado) async {
    try {
      final String baseUrl = await FirebaseFirestore.instance
          .collection('link')
          .doc('link')
          .get()
          .then((value) => value['link']);

      final response = await dio.get(
        '$baseUrl/mensagens-pendentes',
        queryParameters: {'afiliado': afiliado},
        options: Options(headers: {
          "Content-Type": "application/json",
          "x-api-key": "4202@back",
          "ngrok-skip-browser-warning": true
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Erro ao buscar mensagens pendentes: $e');
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> enviarMensagem(
      String emailUser, String phoneNumber, String message) async {
    try {
      final String baseUrl = await FirebaseFirestore.instance
          .collection('link')
          .doc('link')
          .get()
          .then((value) => value['link']);
          
      final response = await dio.post(
        '$baseUrl/enviar-mensagem',
        options: Options(headers: {
          "Content-Type": "application/json",
          "x-api-key": "4202@back",
          "ngrok-skip-browser-warning": true
        }),
        data: {
          'email_user': emailUser,
          'phoneNumber': phoneNumber,
          'message': message,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
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
