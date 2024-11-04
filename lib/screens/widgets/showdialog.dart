 import 'package:flutter/material.dart';

void showDialogApi(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atenção!'),
          content: Text(
              'Não foi possível concluir a operação. Por favor, tente novamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
