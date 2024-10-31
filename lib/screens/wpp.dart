import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:smart_pagamento/classes/api_service.dart';

class ConfiguracaoWhatsApp extends StatefulWidget {
  @override
  _ConfiguracaoWhatsAppState createState() => _ConfiguracaoWhatsAppState();
}

class _ConfiguracaoWhatsAppState extends State<ConfiguracaoWhatsApp> {
  final ApiService apiService = ApiService();
  String? qrCodeData;
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
          qrCodeData =
              base64QrCode; // Usando diretamente base64 sem decodificação
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
      appBar: AppBar(title: Text("Configuração do WhatsApp")),
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
            if (qrCodeData != null)
              PrettyQrView.data(
                data: qrCodeData!,
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(
                    color: Colors.black,
                    roundFactor: 0,
                  ),
                ),
              )
            else
              Text(statusMensagem),
          ],
        ),
      ),
    );
  }
}
