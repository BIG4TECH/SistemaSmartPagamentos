import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'telaLogin.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  String _email = '';
  String _whatsapp = '';
  String _password = '';
  String _confirmPassword = '';
  String erro = '';
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_password == _confirmPassword) {
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          String uid = userCredential.user!.uid;

          await _firestore.collection('users').doc(uid).set({
            'name': _nome,
            'email': _email,
            'whatsapp': _whatsapp,
          });

          final snackBar = SnackBar(
            content: Text('Cadastro concluído: ${userCredential.user!.email}'),
            duration: Duration(seconds: 5), // Duração da SnackBar
          );
          Navigator.pop(context);
          // Exibe a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = const SnackBar(
            content: Text('As senhas não correspondem'),
            duration: Duration(seconds: 5), // Duração da SnackBar
          );
          // Exibe a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            erro = 'Email já cadastrado';
          } else if (e.code == 'weak-password') {
            erro = 'Digite uma senha com mais de 6 digitos';
          } else if (e.code == 'invalid-email') {
            erro = 'Email inválido';
          } else {
            erro = 'Erro ao cadastrar';
          }
        }
        final snackBar = SnackBar(
          content: Text(erro),
          duration: Duration(seconds: 5), // Duração da SnackBar
        );
        // Exibe a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        decoration: const BoxDecoration(
            gradient:  LinearGradient(
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
            margin: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
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
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            topLeft: Radius.circular(20)),
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
                            child: SingleChildScrollView(
                              
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Cadastro',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 38),
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Nome Completo',
                                      ),
                                      keyboardType: TextInputType.name,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, insira seu nome';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        _nome = value;
                                      },
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, insira um e-mail';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        _email = value;
                                      },
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'WhatsApp',
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, insira um número de WhatsApp';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        _whatsapp = value;
                                      },
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Senha',
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, insira uma senha';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        _password = value;
                                      },
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Confirme a senha',
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, confirme a senha';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        _confirmPassword = value;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : ElevatedButton(
                                            onPressed: () {
                                              _signup();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.purple,
                                                minimumSize: Size(300, 42),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                            child: const Text('Cadastrar',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()),
                                        );
                                      },
                                      child: const Text(
                                        'Já possui uma conta? Realize o login!',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.grey),
                const Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Bem-Vindo!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                              color: Colors.white),
                        ),
                      ],
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
}
