import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TotalVendidos extends StatefulWidget {
  const TotalVendidos({super.key});

  @override
  State<StatefulWidget> createState() => TotalVendidosState();
}

class TotalVendidosState extends State<TotalVendidos> {
  int _quantVendidos = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getDataVendidos();
  }

  void getDataVendidos() async {
    setState(() {
      _isLoading = true;
    });

    int cont = 0;

    var vendasSnapshot =
        await FirebaseFirestore.instance.collection('vendas').get();

    var produtosSnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    var itensVendasSnapshot =
        await FirebaseFirestore.instance.collection('itens_vendas').get();

    for (var docvenda in vendasSnapshot.docs) {
      for (var docprod in produtosSnapshot.docs) {
        for (var dociven in itensVendasSnapshot.docs) {
          if (dociven['idproduto'] == docprod.id &&
              docvenda.id == dociven['idvenda']) {
            cont += int.parse(dociven['quantidade'].toString());
          }
        }
      }
    }

    setState(() {
      _quantVendidos = cont;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isLoading
            ? const CircularProgressIndicator()
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.purple,
                      ),
                      child: Center(
                        child: Text(
                          '$_quantVendidos',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Produtos',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Total Vendidos'),
                      ],
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: getDataVendidos,
                        icon: const Icon(Icons.restart_alt_rounded))
                  ],
                ),
              ),
      ],
    );
  }
}
