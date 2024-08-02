// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroPessoa.dart';

import '/screens/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Navigate to the home screen if login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } on FirebaseAuthException catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Falha no login'),
            content: Text('Email ou senha incorretos'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [
              Color.fromRGBO(89, 19, 165, 1.0),
              Color.fromRGBO(93, 21, 178, 1.0),
              Color.fromRGBO(123, 22, 161, 1.0),
              Color.fromRGBO(153, 27, 147, 1.0),
            ])),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 200, vertical: 100),
            //padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1, // espalhamento
                      blurRadius: 5, // desfoque
                      offset: Offset(0, 0) // posição x,y
                      )
                ]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Bem-Vindo!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38, color: Colors.white),),
                       
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Colors.grey),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1, // espalhamento
                              blurRadius: 5, // desfoque
                              offset: Offset(0, 0) // posição x,y
                              )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, bottom: 16.0, right: 70, left: 70),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 38),
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Por favor, insira um e-mail';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(labelText: 'Senha'),
                              obscureText: true,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Por favor, insira uma senha';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      minimumSize: Size(300 , 42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      )
                                    ),
                                    
                                    child: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupScreen()),
                                );
                              },
                              child:
                                  Text('Ainda não possui uma conta? Cadastre-se!',),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
