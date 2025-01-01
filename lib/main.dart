import 'package:flutter/material.dart';

import 'package:http/http.dart' as http; 
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=a8af02a6";


void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData( //definindo um tema para o app
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  ));
}


Future<Map> getData() async{
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final btcController = TextEditingController();

  double dolar = 0.0;
  double btc = 0.0;

  _realChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    btcController.text = (real/btc).toStringAsFixed(2);
  }

  _dolarChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar / btc).toStringAsFixed(2);
  }

  _btcChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }

    double btc = double.parse(text);
    realController.text = (btc * this.btc).toStringAsFixed(2);
    dolarController.text = (btc * this.btc / dolar).toStringAsFixed(2);
  }

  
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    btcController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(  //usado quando você quer que sua tela retorne um dado no futuro. Nesse caso quando for colocar o valor para converter, ele vai até a API, pega os dados atuais e converte para o valor que você deseja, para isso você usa o FutureBuilder, porque enquanto ele carrega os dados, exibe alguma mensagem que você deseja. 
        future: getData(), //informa o que vai retornar no futuro
        builder: (context, snapshot){ //informar o que vai retornas em cada um dos casos
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                  ),
                );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro :(",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                  textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data?["results"]?["currencies"]?["USD"]?["buy"];
                btc = snapshot.data?["results"]?["currencies"]?["BTC"]?["buy"];
                return SingleChildScrollView(
                  padding:EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.monetization_on,
                      size: 150.0,
                      color: Colors.amber,),
                      builderTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      builderTextField("Dolares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      builderTextField("BTC", "₿", btcController, _btcChanged),
                    ],
                  ),
                );
              }
          }

        }),
    );
  }
}


Widget builderTextField(String labelText, String prefixText, TextEditingController c, ValueChanged<String> f){

  return TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: Colors.amber
            ),
            prefixText: prefixText,
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0
          ),
          onChanged: f,
          keyboardType: TextInputType.number,
        );
}
