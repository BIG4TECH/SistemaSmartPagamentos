// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroCliente.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroFiliado.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroVenda.dart';
import 'package:smart_pagamento/screens/listas/telaClientes.dart';
import 'package:smart_pagamento/screens/listas/telaFiliados.dart';
import 'package:smart_pagamento/screens/listas/telaVendas.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';

import '../cadastros/telaCadastroProduto.dart';
import '../listas/telaProdutos.dart';

Widget menuDrawer(BuildContext context, String email, String tipoUser) {
  return Drawer(
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(40),
          width: double.infinity,
          height: 230,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientBtn(),
              begin: Alignment.topLeft,
              end: Alignment(1.0, 3.0),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                              "https://static.vecteezy.com/system/resources/thumbnails/005/545/335/small/user-sign-icon-person-symbol-human-avatar-isolated-on-white-backogrund-vector.jpg"),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Minhas Listas",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Desenvolvido por BIG4TECH",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )
              ],
            ),
          ),
        ),
        tipoUser == 'master' ? ListTile(
          leading: Icon(
            Icons.new_label,
            color: corPadrao(),
          ),
          title: Text(
            "Novo Produto",
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductRegisterScreen(email: email)));
          },
        ) : SizedBox(),
        ListTile(
          leading: Icon(Icons.local_offer, color: corPadrao()),
          title: Text(
            tipoUser == 'master' ? "Meus Produtos" : 'Produtos',
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductListScreen(
                          email: email,
                          tipoUser: tipoUser
                        )));
          },
        ),
        ListTile(
          leading: Icon(Icons.person_add_alt_1_rounded, color: corPadrao()),
          title: Text(
            "Novo Cliente",
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegistraCliente(email: email)));
          },
        ),
        ListTile(
          leading: Icon(Icons.people_alt_rounded, color: corPadrao()),
          title: Text(
            "Meus Clientes",
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClienteListScreen(email: email, tipoUser: tipoUser)));
          },
        ),
        /*
        ListTile(
          leading: Icon(Icons.supervised_user_circle, color: corPadrao()),
          title: Text(
            "Novo Filiado",
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegistraFiliado(email: email)));
          },
        ),
        ListTile(
          leading: Icon(Icons.supervised_user_circle, color: corPadrao()),
          title: Text(
            "Meus Filiados",
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FiliadoListScreen(email: email)));
          },
        ),
        */
        ListTile(
          leading: Icon(Icons.add_shopping_cart_rounded, color: corPadrao()),
          title: Text(
            "Nova Venda",
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegistraVenda(email: email)));
          },
        ),
        ListTile(
          leading:
              Icon(Icons.shopping_cart_checkout_rounded, color: corPadrao()),
          title: Text(
            "Minhas Vendas",
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VendasListScreen(email, tipoUser)));
          },
        ),
      ],
    ),
  );
}
