import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:smart_pagamento/screens/widgets/charts/totalVendidos.dart';

class RegistraVenda extends StatefulWidget {
  final String? vendaId;

  RegistraVenda({super.key, this.vendaId});

  @override
  _RegistraVendaState createState() => _RegistraVendaState();
}

class _RegistraVendaState extends State<RegistraVenda> {
  NumberFormat formatoDouble = NumberFormat("#,##0.00", "pt_BR");
  final _formKey = GlobalKey<FormState>();
  double _totalLiq = 0;
  double _totalVenda = 0;
  String? _dadosCliente;
  String _dadosProduto = '';
  String? _clienteId;
  String? _produtoId;

  //Listas para visualizar no dropdownsearch
  List<String> _listClienteDrop = [];
  List<String> _listProdutoDrop = [];

  //lista para os produtos deletados
  List<String> _listProdutoDropDeleted = [];

  //Lista dos produtos escolhidos
  List<String> _listProdutosEscolhidos = [];

  //Lista da quantidade dos produtos escolhidos
  List<int> _listQuantProd = [];

  //Lista do preço dos produtos
  List<double?> _listPriceProd = [];

  //Lista do valor de desconto
  List<int?> _listDescontoProd = [];

  //Lista do valor descontado
  List<double> _listValorDescontadoProd = [];

  List<double> _listValorBrutoProd = [];

  List<double> _listValorLiqProd = [];

  List<String?> _listProdutoId = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _setListCliente();
    _setListProduto();

    if (widget.vendaId != null) {
      _loadVenda();
    }
  }

  //ADICIONAR OS DADOS DO CLIENTE NA LISTA DO DROPDOWNSEARCH
  void _setListCliente() async {
    FirebaseFirestore.instance
        .collection('clientes')
        .snapshots()
        .listen((query) {
      setState(() {
        _listClienteDrop = [];

        query.docs.forEach((doc) {
          setState(() {
            _listClienteDrop.add(
                '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}');
          });
        });
      });
    });
  }

  //ADICIONAR OS DADOS DO PRODUTO NA LISTA DO DROPDOWNSEARCH
  void _setListProduto() async {
    FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((query) {
      setState(() {
        _listProdutoDrop = [];

        query.docs.forEach((doc) {
          setState(() {
            _listProdutoDrop.add(
                '${doc['name']} | Preço: ${doc['price']} | Desconto: ${doc['desconto']}%');
          });
        });
      });
    });
  }

  //BUSCAR E INSERIR O ID DO CLIENTE
  Future<String?> fetchAndSetIdCliente(String? cliSelecionado) async {
    var query = await FirebaseFirestore.instance.collection('clientes').get();
    for (var doc in query.docs) {
      if (cliSelecionado ==
          '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}') {
        return doc.id;
      }
    }
    return null;
  }

  //BUSCAR E INSERIR O ID DO PRODUTO
  Future<String?> fetchAndSetIdProduto(String? prodSelecionado) async {
    var query = await FirebaseFirestore.instance.collection('products').get();
    for (var doc in query.docs) {
      if (prodSelecionado ==
          '${doc['name']} | Preço: ${doc['price']} | Desconto: ${doc['desconto']}%') {
        return doc.id;
      }
    }
    return null;
  }

  //buscar preço do produto
  Future<double?> fetchPriceProduto(String? prodSelecionado) async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    for (var doc in querySnapshot.docs) {
      if (prodSelecionado ==
          '${doc['name']} | Preço: ${doc['price']} | Desconto: ${doc['desconto']}%') {
        return doc['price'];
      }
    }
    return null;
  }

  //BUSCAR DESCONTO DO PRODUTO
  Future<int?> fetchDescontoProduto(String? prodSelecionado) async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    for (var doc in querySnapshot.docs) {
      if (prodSelecionado ==
          '${doc['name']} | Preço: ${doc['price']} | Desconto: ${doc['desconto']}%') {
        return doc['desconto'];
      }
    }
    return null;
  }

  //ADICIONAR DADOS DO PRODUTO NA LISTA DE PRODUTOS ESCOLHIDOS
  void _addProduto(String? dadosProduto, int quantidade, double? price,
      int? desconto, String? produtoId) {
    double valorDescontado = 0;

    setState(() {
      if (price != null) {
        _totalVenda += quantidade * price;

        if (quantidade > 1) {
          valorDescontado = ((desconto ?? 0.0) / 100) * (quantidade * price);
        }

        _totalLiq += (quantidade * price) - valorDescontado;
      }

      _listProdutoId.add(_produtoId);
      _listValorLiqProd.add((quantidade * (price ?? 0)) - valorDescontado);
      _listValorBrutoProd.add(quantidade * (price ?? 0));
      _listValorDescontadoProd.add(valorDescontado);
      _listProdutosEscolhidos.add('$dadosProduto | Quant.: $quantidade');
      _listQuantProd.add(quantidade);
      _listPriceProd.add(price);
      _listDescontoProd.add(desconto);
      _listProdutoDrop.remove(dadosProduto);
      _listProdutoDropDeleted.add(dadosProduto.toString());
    });
  }

  //REMOVER DADOS DO PRODUTO DA LISTA DE PRODUTOS ESCOLHIDOS
  void _removeProduto(int index) {
    double? price = _listPriceProd[index];
    int quantidade = _listQuantProd[index];
    double valorDescontado = _listValorDescontadoProd[index];

    setState(() {
      if (price != null) {
        _totalVenda -= quantidade * price;

        _totalLiq -= (quantidade * price) - valorDescontado;
      }

      _listProdutoId.removeAt(index);
      _listValorLiqProd.removeAt(index);
      _listValorBrutoProd.removeAt(index);
      _listDescontoProd.removeAt(index);
      _listValorDescontadoProd.removeAt(index);
      _listProdutosEscolhidos.removeAt(index);
      _listQuantProd.removeAt(index);
      _listPriceProd.removeAt(index);
      _listProdutoDrop.add(_listProdutoDropDeleted[index]);
      _listProdutoDropDeleted.removeAt(index);

      if (_listProdutosEscolhidos.isEmpty) {
        _totalVenda = 0;
        _totalLiq = 0;
      }
    });
  }

  //Showdialog para selecionar produtos e a quantidade
  void _setProdutosAndQuant(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    int quantidade = 1;
    double? price;
    int? desconto;
    _dadosProduto = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text(
              "Escolha o Produto",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            content: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //ESCOLHER O PRODUTO
                    DropdownSearch<String>(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _dadosProduto == '') {
                          return 'Por favor, escolha o produto!';
                        }
                        return null;
                      },
                      popupProps: const PopupProps.menu(
                          showSelectedItems: true,
                          //disabledItemFn: (String s) => s.startsWith('I'),
                          showSearchBox: true),
                      items: _listProdutoDrop,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                          labelText: "Produto",
                          hintText: "Selecione um dos produtos.",
                        ),
                      ),
                      onChanged: (String? prodSelecionado) {
                        setState(() async {
                          _dadosProduto = prodSelecionado.toString();
                          _produtoId =
                              await fetchAndSetIdProduto(prodSelecionado);
                          price = await fetchPriceProduto(prodSelecionado);
                          desconto =
                              await fetchDescontoProduto(prodSelecionado);
                        });
                      },
                      selectedItem: _dadosProduto,
                    ),

                    const SizedBox(height: 20),

                    //QUANTIDADE DO PRODUTO
                    Text(
                      'Quantidade: $quantidade',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //BOTÃO MENOS
                        ElevatedButton(
                            onPressed: () {
                              if (quantidade > 1) {
                                setState(() {
                                  quantidade--;
                                });
                              }
                            },
                            child: const Text('-1')),

                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                quantidade++;
                              });
                            },
                            child: const Text('+1')),
                      ],
                    ),
                  ],
                )),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size(20, 42),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: const Text(
                  "Adicionar",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addProduto(
                        _dadosProduto, quantidade, price, desconto, _produtoId);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  //remover da lista de produtos escolhidos
  Widget _removeAtListProdutosEscolhidos(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Deseja excluir o produto?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _removeProduto(index);
                          Navigator.pop(context);
                        });
                      },
                      child: const Text('Excluir'))
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _loadVenda() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot venda = await FirebaseFirestore.instance
        .collection('vendas')
        .doc(widget.vendaId)
        .get();

    _dadosCliente = venda['cliente'];
    //mostrar em uma área os itens da venda com a coleção itens_vendas
    //valor da venda

    setState(() {
      _isLoading = false;
    });
  }

  void _registerOrEditVenda() async {
    DateTime datahora = DateTime.now();
    DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');
    String nomeCliente = '';
    TotalVendidosState totalVendidos = TotalVendidosState();

    if (_formKey.currentState!.validate()) {
      var query = await FirebaseFirestore.instance.collection('clientes').get();
      for (var doc in query.docs) {
        if (_dadosCliente ==
            '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['whatsapp']}') {
           nomeCliente = doc['name'];
        }
      }
      if (widget.vendaId == null) {
        //Registrar venda
        DocumentReference vendaRef =
            await FirebaseFirestore.instance.collection('vendas').add({
          'cliente': _dadosCliente,
          'nome_cliente': nomeCliente,
          'idcliente': _clienteId,
          'total_bruto': _totalVenda,
          'total_liq': _totalLiq,
          'data_hora': formatoData.format(datahora),
          'data': datahora
        });

        //registrar itens_vendas
        for (var index = 0; index < _listProdutosEscolhidos.length; index++) {
          await FirebaseFirestore.instance.collection('itens_vendas').add({
            'idvenda': vendaRef.id,
            'produto': _listProdutosEscolhidos[index],
            'idproduto': _listProdutoId[index],
            'quantidade': _listQuantProd[index],
            'total_bruto_prod': _listValorBrutoProd[index],
            'valor_descontado': _listValorDescontadoProd[index],
            'total_liq_prod': _listValorLiqProd[index]
          });
        }
      } else {
        //Atualizar venda
        await FirebaseFirestore.instance
            .collection('vendas')
            .doc(widget.vendaId)
            .update({
          'cliente': _dadosCliente,
          'idcliente': _clienteId,
          'total_bruto': _totalVenda,
          'total_liq': _totalLiq,
          'data_hora': formatoData.format(datahora),
          'data': datahora
        });
      }
      setState(() {
        totalVendidos.getDataVendidos;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Venda ${widget.vendaId == null ? 'registrada' : 'atualizada'} com sucesso!')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(89, 19, 165, 1.0),
                      Color.fromRGBO(93, 21, 178, 1.0),
                      Color.fromRGBO(123, 22, 161, 1.0),
                      Color.fromRGBO(153, 27, 147, 1.0),
                    ],
                  ),
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                              child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 80),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 0),
                                )
                              ],
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.vendaId == null
                                            ? 'Registro de Venda'
                                            : 'Edição de Venda',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          //column de valores

                                          Expanded(
                                              child: Container(
                                            //color: Colors.amber,
                                            height: 400,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Card(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    child: Text(
                                                        'Total Bruto: R\$${formatoDouble.format(_totalVenda)}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white))),
                                                Card(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    child: Text(
                                                        'Total Liq.: R\$${formatoDouble.format(_totalLiq)}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white))),
                                              ],
                                            ),
                                          )),

                                          //column de cliente e produto
                                          Expanded(
                                              child: Card(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: (Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          //CLIENTES
                                                          const Text('Clientes',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      20)),

                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          DropdownSearch<
                                                              String>(
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty ||
                                                                  _listProdutosEscolhidos
                                                                      .isEmpty) {
                                                                return 'Por favor, escolha o cliente e/ou produto!';
                                                              }
                                                              return null;
                                                            },
                                                            popupProps: const PopupProps
                                                                .menu(
                                                                showSelectedItems:
                                                                    true,
                                                                //disabledItemFn: (String s) => s.startsWith('I'),
                                                                showSearchBox:
                                                                    true),
                                                            items:
                                                                _listClienteDrop,
                                                            dropdownDecoratorProps:
                                                                const DropDownDecoratorProps(
                                                              dropdownSearchDecoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    "Selecione um dos clientes.",
                                                                //hintText: "Selecione um dos clientes.",
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              30.0)),
                                                                ),
                                                              ),
                                                            ),
                                                            onChanged: (String?
                                                                cliSelecionado) {
                                                              setState(
                                                                  () async {
                                                                _dadosCliente =
                                                                    cliSelecionado;
                                                                _clienteId =
                                                                    await fetchAndSetIdCliente(
                                                                        cliSelecionado);
                                                              });
                                                            },
                                                            selectedItem:
                                                                _dadosCliente,
                                                          ),
                                                          const SizedBox(
                                                              height: 20),

                                                          //PRODUTOS
                                                          const Text('Produtos',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      20)),

                                                          //VISUALIZAÇÃO DOS PRODUTOS DA VENDA
                                                          SizedBox(
                                                            height: 200,
                                                            child: ListView
                                                                .builder(
                                                                    itemCount:
                                                                        _listProdutosEscolhidos
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return Card(
                                                                          child: ListTile(
                                                                              title: Text(_listProdutosEscolhidos[index]),
                                                                              subtitle: Text('Total Bruto: ${_listValorBrutoProd[index]} | Desconto Aplicado: ${_listValorDescontadoProd[index]} | Valor Liq.: ${_listValorLiqProd[index]}'),
                                                                              trailing: _removeAtListProdutosEscolhidos(index)));
                                                                    }),
                                                          ),

                                                          //BOTÃO PARA ADICIONAR PRODUTO NA VENDA
                                                          ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .purple,
                                                                minimumSize:
                                                                    const Size(
                                                                        2000,
                                                                        42),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                              ),
                                                              onPressed: () {
                                                                _setProdutosAndQuant(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Adicionar Produtos',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                        ],
                                                      )))))
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      //BOTÃO DE CONFIRMAÇÃO
                                      Center(
                                          child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          minimumSize: const Size(2000, 42),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        ),
                                        onPressed: _registerOrEditVenda,
                                        child: Text(
                                          widget.vendaId == null
                                              ? 'Registrar Venda'
                                              : 'Editar Venda',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ))
                                    ],
                                  ),
                                )),
                          ))));
                })));
  }
}
