import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_pagamento/routes/api_service.dart';
import 'package:smart_pagamento/widgets/cores.dart';
import 'package:smart_pagamento/widgets/textfield.dart';

class ConfiguracaoWhatsApp extends StatefulWidget {
  final String emailUser;

  ConfiguracaoWhatsApp(this.emailUser);

  @override
  _ConfiguracaoWhatsAppState createState() => _ConfiguracaoWhatsAppState();
}

class _ConfiguracaoWhatsAppState extends State<ConfiguracaoWhatsApp> {
  final ApiService apiService = ApiService();
  Uint8List? qrCodeBytes;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String statusMensagem = "Inicie a sessão para obter o QR Code.";
  MaskedTextController numeroCtrl =
      MaskedTextController(mask: '+00 (00) 00000-0000');
  Timer? statusTimer;
  bool _isLoading = false;
  TextEditingController _primeiraCtrlr = TextEditingController();
  TextEditingController _segundaCtrlr = TextEditingController();
  TextEditingController _acessTokenCtrlr = TextEditingController();
  TextEditingController _publicKeyCtrlr = TextEditingController();

  String msgCobranca =
      '\nClique no link abaixo para renovar sua assinatura:\n https://4bda-131-0-245-253.ngrok-free.app/checkout/renovar.html?';

  @override
  void initState() {
    super.initState();
    verificarStatusWhatsApp();
    verifyMensagens();
    verifyToken();
  }

  void configurarMensagem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('mensagem')
            .doc(widget.emailUser)
            .set({
          'email_user': widget.emailUser,
          'intervalo': 3,
          'primeira': _primeiraCtrlr.text + msgCobranca,
          'segunda': _segundaCtrlr.text + msgCobranca,
        });

        const snackBar = SnackBar(
          content: Text('Mensagem Configurada com sucesso!'),
          duration: Duration(seconds: 5),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        String erro = "Erro ao configurar mensagem: $e";
        final snackBar = SnackBar(
          content: Text(erro),
          duration: Duration(seconds: 5),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void configurarTokenMercadoPago() async {
    if (_formKey2.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.emailUser)
            .update({
          'public_key': _publicKeyCtrlr.text,
          'acess_token': _acessTokenCtrlr.text,
        });

        const snackBar = SnackBar(
          content: Text('Token Configurado com sucesso!'),
          duration: Duration(seconds: 5),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        String erro = "Erro ao configurar mensagem: $e";
        final snackBar = SnackBar(
          content: Text(erro),
          duration: Duration(seconds: 5),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> verifyToken() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.emailUser)
          .get()
          .then((value) {
        if (value.exists) {
          setState(() {
            _acessTokenCtrlr.text = value['acess_token'];
            _publicKeyCtrlr.text = value['public_key'];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> verifyMensagens() async {
    try {
      await FirebaseFirestore.instance
          .collection('mensagem')
          .doc(widget.emailUser)
          .get()
          .then((value) {
        if (value.exists) {
          setState(() {
            _primeiraCtrlr.text = value['primeira'];
            _segundaCtrlr.text = value['segunda'];
          });
        }
      });
    } catch (e) {
      print(e);
    }
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
          qrCodeBytes = null;
          numeroCtrl.text = status['body']['phoneNumber'];

          statusMensagem = "Número conectado: \n${numeroCtrl.text}";
        });

        // Parar o timer se já conectado
        statusTimer?.cancel();
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

          // Iniciar o Timer para verificar o status a cada 2 segundos
          statusTimer = Timer.periodic(Duration(seconds: 2), (timer) {
            verificarStatusWhatsApp();
          });
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
  void dispose() {
    statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Configurações",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
              centerTitle: true,
              backgroundColor: corPadrao(),
              bottom: const TabBar(
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                      icon: FaIcon(FontAwesomeIcons.whatsapp,
                          color: Colors.white),
                      text: 'Whatsapp'),
                  Tab(
                      icon: FaIcon(
                        FontAwesomeIcons.message,
                        color: Colors.white,
                      ),
                      text: 'Mensagens'),
                  Tab(
                      icon: FaIcon(FontAwesomeIcons.key, color: Colors.white),
                      text: 'Token'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                //QR CODE
                Center(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.1),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Column(
                              children: [
                                if (qrCodeBytes != null)
                                  Image.memory(
                                    qrCodeBytes!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  )
                                else
                                  Card(
                                      child: ListTile(
                                    leading: FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.green,
                                    ),
                                    title: Text(
                                      statusMensagem,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
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
                                        minimumSize:
                                            Size(size.width * 0.04, 50),
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    onPressed: iniciarSessao,
                                    child: Text("Iniciar Sessão do WhatsApp",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.height * 0.022,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                SizedBox(height: 25),
                              ],
                            ),
                          ],
                        ),
                      )),
                ),

                //MENSAGEM
                Center(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Text(
                      // 'Configurar Mensagem de Cobrança',
                      // style: TextStyle(fontWeight: FontWeight.w500),
                      //),
                      //SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: size.width * 0.1),
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _primeiraCtrlr,
                                decoration: inputDec('Primeira Mensagem'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, informe a primeira mensagem';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: size.width * 0.1),
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _segundaCtrlr,
                                decoration: inputDec('Segunda Mensagem'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, informe a segunda mensagem';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            //atenção
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.1),
                              child: Card(
                                child: ListTile(
                                  leading: FaIcon(
                                    FontAwesomeIcons.triangleExclamation,
                                  ),
                                  title: Text(
                                    'OBS.: O link de renovação da assinatura será enviado no final de cada mensagem!',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
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
                                    minimumSize: Size(size.width * 0.4, 50),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                onPressed: configurarMensagem,
                                child: Text("Salvar Mensagens",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size.height * 0.022,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

                //MERCADO PAGO
                Center(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ///Text(
                      //  'Configurar Token do Mercado Pago',
                      //  style: TextStyle(
                      //      fontWeight: FontWeight.w500, fontSize: 20),
                      //),
                      SizedBox(height: 10),
                      Form(
                        key: _formKey2,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: size.width * 0.1),
                              child: TextFormField(
                                controller: _acessTokenCtrlr,
                                decoration:
                                    inputDec('Acess Token (Token de Acesso)'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, informe o token de acesso';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: size.width * 0.1),
                              child: TextFormField(
                                controller: _publicKeyCtrlr,
                                decoration:
                                    inputDec('Public Key (Chave Pública)'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, informe a Public Key';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
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
                                    minimumSize: Size(size.width * 0.4, 50),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                onPressed: configurarTokenMercadoPago,
                                child: Text("Salvar Token",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size.height * 0.022,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            )));
  }
}
