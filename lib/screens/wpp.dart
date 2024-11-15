import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
//import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:smart_pagamento/classes/api_service.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';

class ConfiguracaoWhatsApp extends StatefulWidget {
  final String emailUser;

  ConfiguracaoWhatsApp(this.emailUser);

  @override
  _ConfiguracaoWhatsAppState createState() => _ConfiguracaoWhatsAppState();
}

class _ConfiguracaoWhatsAppState extends State<ConfiguracaoWhatsApp> {
  final ApiService apiService = ApiService();
  Uint8List? qrCodeBytes;
  String statusMensagem = "Inicie a sessão para obter o QR Code.";
  MaskedTextController numeroCtrl =
      MaskedTextController(mask: '+00 (00) 00000-0000');

  @override
  void initState() {
    super.initState();
    verificarStatusWhatsApp();
  }

  Future<void> verificarStatusWhatsApp() async {
    setState(() {
      statusMensagem = "Verificando status do WhatsApp...";
    });

    try {
      final status = await apiService.verificarStatusWhatsApp(widget.emailUser);
      print('STATUS: $status');
      if (status['body']['connected'] == true) {
        setState(() {
          numeroCtrl.text = status['body']['phoneNumber'];

          statusMensagem = "Número conectado: ${numeroCtrl.text}";
        });
      } else {
        setState(() {
          statusMensagem = "Nenhum dispositivo conectado.";
        });
      }
    } catch (e) {
      setState(() {
        statusMensagem = "Erro ao verificar status: $e";
      });
    }
  }

  Future<void> iniciarSessao() async {
    setState(() {
      statusMensagem = "Iniciando sessão...";
    });

    try {
      final base64QrCode =
          await apiService.iniciarSessaoWhatsapp(widget.emailUser);
      if (base64QrCode != null) {
        setState(() {
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
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Configuração do WhatsApp",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            ),
          ),
          centerTitle: true,
          backgroundColor: corPadrao(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (qrCodeBytes != null)
                  Image.memory(
                    qrCodeBytes!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  )
                else
                  Text(statusMensagem),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientBtn(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: iniciarSessao,
                    child: Text("Iniciar Sessão do WhatsApp",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: size.height * 0.022,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                
                
                
              ],
            ),
          ),
        ));
  }
}
