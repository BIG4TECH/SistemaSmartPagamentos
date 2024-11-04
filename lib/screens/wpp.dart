import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
//import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:smart_pagamento/classes/api_service.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';

class ConfiguracaoWhatsApp extends StatefulWidget {
  @override
  _ConfiguracaoWhatsAppState createState() => _ConfiguracaoWhatsAppState();
}

class _ConfiguracaoWhatsAppState extends State<ConfiguracaoWhatsApp> {
  final ApiService apiService = ApiService();
  Uint8List? qrCodeBytes;
  String statusMensagem = "Inicie a sessão para obter o QR Code.";

  Future<void> iniciarSessao() async {
    setState(() {
      statusMensagem = "Iniciando sessão...";
    });

    try {
      final base64QrCode = await apiService.iniciarSessaoWhatsapp();
      print(base64QrCode);
      if (base64QrCode != null) {
        setState(() {
          // Remover o prefixo 'data:image/png;base64,' antes de decodificar
          final base64String = base64QrCode.split(',')[1];
          qrCodeBytes = base64Decode(base64String);
          statusMensagem = "Escaneie o QR Code com o WhatsApp.";
        });
      } else {
        setState(() {
          statusMensagem = "QR Code não encontrado na resposta.";
        });
      }
    } catch (e) {
      setState(() {
        statusMensagem = "Erro ao iniciar sessão: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Configuração do WhatsApp", style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 38,
          ),),
          centerTitle: true,
        backgroundColor: corPadrao(),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: iniciarSessao,
              child: Text("Iniciar Sessão do WhatsApp"),
            ),
            SizedBox(height: 20),
            if (qrCodeBytes != null)
              Image.memory(
                qrCodeBytes!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              )
            else
              Text(statusMensagem),
          ],
        ),
      ),
    );
  }
}
