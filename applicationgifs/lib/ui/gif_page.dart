import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    var specificImageToShared = _gifData["images"]["fixed_height"]["url"];

    return Scaffold(
      appBar: AppBar(
        title: Text(_gifData["title"]),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                Share.share(specificImageToShared);
              },
              icon: const Icon(Icons.share))
        ],
      ),
      body: Center(
        child: Image.network(specificImageToShared),
      ),
      backgroundColor: Colors.black,
    );
  }
}
