import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/classes/api_service.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
//import 'package:smart_pagamento/screens/widgets/editarNumero.dart';
import 'package:smart_pagamento/screens/widgets/exibirLink.dart';
import 'package:smart_pagamento/screens/widgets/showdialog.dart';

import '../cadastros/telaCadastroProduto.dart';

class ProductListScreen extends StatefulWidget {
  final String? email;
  //final String tipoUser;
  final String idUser;

  const ProductListScreen({super.key, required this.email, required this.idUser
      //required this.tipoUser
      });

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Meus Produtos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            )),
        centerTitle: true,
        backgroundColor: corPadrao(),
      ),
      body: Container(
        padding: size.width <= 720
            ? const EdgeInsets.only(top: 40, left: 10, right: 10)
            : const EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          children: [
            TextField(
              cursorColor: corPadrao(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                labelText: 'Pesquisar Produto',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color:
                        corPadrao(), // Cor da borda quando o campo está focado
                    width: 3.0, // Espessura da borda quando o campo está focado
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('email_user', isEqualTo: widget.email)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs.where((product) {
                    return product['name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  if (products.isEmpty) {
                    return const Center(
                        child: Text('Nenhum produto encontrado',
                            style: TextStyle(fontWeight: FontWeight.bold)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final String recurrence;

                      switch (product['recurrencePeriod']) {
                        case 1:
                          recurrence = 'Mensal';
                          break;
                        case 2:
                          recurrence = 'Bimestral';
                          break;
                        case 3:
                          recurrence = 'Trimestral';
                          break;
                        case 6:
                          recurrence = 'Semestral';
                          break;
                        case 12:
                          recurrence = 'Anual';
                          break;
                        default:
                          recurrence = 'nada';
                          break;
                      }

                      return Card(
                        //color: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            product['name'],
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Preço: R\$${product['price']}\nRecorrência: $recurrence',
                            //style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductRegisterScreen(
                                        productId: product.id,
                                        email: widget.email,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      //backgroundColor: Colors.black87,
                                      title: const Text(
                                        'Deseja excluir o produto?',
                                        //style:TextStyle(color: Colors.white)
                                      ),

                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancelar',
                                              style: TextStyle(
                                                  color: Colors.grey.shade400)),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: gradientBtn(),
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                ApiService apiService =
                                                    ApiService();

                                                var responseDelete =
                                                    await apiService
                                                        .deletarPlano(
                                                            product['plan_id']);

                                                if (responseDelete['status'] ==
                                                    200) {
                                                  _deleteProduct(product.id);
                                                  Navigator.pop(context);
                                                } else {
                                                  showDialogApi(context);
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  fixedSize: Size(
                                                      size.width * 0.1,
                                                      size.height * 0.01),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              child: Text('Excluir',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          size.height * 0.022,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientBtn(),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.link,
                                      color: Colors.white),
                                  onPressed: () {
                                    //String valor =formatarNumero(product['price']);
                                        
                                    showLinkModal(context,
                                        "http://131.0.245.253:3030/checkout/index.html?i=${product.id}");
                                        
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(String productId) {
    FirebaseFirestore.instance.collection('products').doc(productId).delete();
  }
}
