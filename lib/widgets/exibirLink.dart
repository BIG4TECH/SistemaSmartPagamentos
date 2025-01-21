import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';

void showLinkModal(BuildContext context, String link) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartilhar Link',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              link,
              style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    FlutterClipboard.copy(link).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Link copiado!')),
                      );
                    });
                  },
                  icon: Icon(Icons.copy),
                  label: Text('Copiar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Share.share(link);
                  },
                  icon: Icon(Icons.share),
                  label: Text('Compartilhar'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
