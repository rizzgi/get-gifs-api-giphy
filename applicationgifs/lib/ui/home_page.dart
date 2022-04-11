import 'dart:convert';

import 'package:share/share.dart';
import 'package:applicationgifs/ui/gif_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _offset = 0;
  var _search;
  late final String _link1 =
      "https://api.giphy.com/v1/gifs/search?api_key=0B1IMTZdYvUIPFd2WJCGSwWkxlD8LQ4N&q=$_search&limit=19&offset=$_offset&rating=g&lang=en";
  final String _link2 =
      "https://api.giphy.com/v1/gifs/trending?api_key=0B1IMTZdYvUIPFd2WJCGSwWkxlD8LQ4N&limit=24&rating=g";
  final String imgLogo =
      "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif";

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(imgLogo),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
                decoration: const InputDecoration(
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
                onSubmitted: (text) {
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
                }),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGifTable(context, snapshot);
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search.isEmpty) {
      response = await http.get(Uri.parse(_link2));
    } else {
      response = await http.get(Uri.parse(_link1));
    }
    return json.decode(response.body);
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length) {
            var snap =
                snapshot.data["data"][index]["images"]["fixed_height"]["url"];
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GifPage(snapshot.data["data"][index])));
                },
                onLongPress: () {
                  Share.share(snap);
                },
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snap,
                  height: 300,
                  fit: BoxFit.cover,
                ));
          } else {
            return Container(
                child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    "Carregar mais",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ));
          }
        });
  }
}
