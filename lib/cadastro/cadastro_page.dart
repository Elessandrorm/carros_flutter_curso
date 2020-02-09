import 'dart:io';

import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/carros/home_page.dart';
import 'package:carros/pages/login/login_page.dart';
import 'package:carros/utils/alert.dart';
import 'package:carros/utils/nav.dart';
import 'package:carros/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _tNome = TextEditingController();
  final _tEmail = TextEditingController();
  final _tSenha = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File _file;

  final _focusNome = FocusNode();
  final _focusEmail = FocusNode();
  final _focusSenha = FocusNode();

  var _progress = false;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Cadastro"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _body(context),
      ),
    );
  }

  _body(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          _headerFoto(),
          Text(
            "Clique na imagem para tirar uma foto",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Divider(),
          AppText(
            "Nome",
            "Digite o seu nome",
            controller: _tNome,
            keyboardType: TextInputType.text,
            validator: _validateNome,
            textInputAction: TextInputAction.next,
            focusNode: _focusNome,
            nextFocus: _focusEmail,
          ),
          AppText(
            "Email",
            "Digite o seu email",
            controller: _tEmail,
            keyboardType: TextInputType.text,
            validator: _validateLogin,
            textInputAction: TextInputAction.next,
            focusNode: _focusEmail,
            nextFocus: _focusSenha,
          ),
          AppText(
            "Senha",
            "Digite a senha",
            controller: _tSenha,
            keyboardType: TextInputType.number,
            validator: _validateSenha,
            focusNode: _focusSenha,
            password: true,
          ),
          Container(
            height: 46,
            margin: EdgeInsets.only(top: 20),
            child: RaisedButton(
              color: Colors.blue,
              child: _progress
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : Text(
                      "Cadastrar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
              onPressed: () {
                _onClickCadastrar(context);
              },
            ),
          ),
          Container(
            height: 46,
            margin: EdgeInsets.only(top: 20),
            child: RaisedButton(
              color: Colors.white,
              child: Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 22,
                ),
              ),
              onPressed: () {
                _onClickCancelar(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _validateNome(String text) {
    if (text.isEmpty) {
      return "Informe o nome";
    }

    return null;
  }

  String _validateLogin(String text) {
    if (text.isEmpty) {
      return "Informe o email";
    }

    return null;
  }

  String _validateSenha(String text) {
    if (text.isEmpty) {
      return "Informe a senha";
    }
    if (text.length <= 2) {
      return "Senha precisa ter mais de 2 números";
    }

    return null;
  }

  _onClickCancelar(context) {
    push(context, LoginPage(), replace: true);
  }

  _onClickCadastrar(context) async {
    print("Cadastrar!");

    String nome = _tNome.text;
    String email = _tEmail.text;
    String senha = _tSenha.text;

    print("Nome $nome, Email $email, Senha $senha");

    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _progress = true;
    });

    final service = FirebaseService();
    final response = await service.cadastrar(nome, email, senha, file: _file);

    if (response.ok) {
      push(context, HomePage(), replace: true);
    } else {
      alert(context, response.msg);
    }

    setState(() {
      _progress = false;
    });
  }

  _headerFoto() {
    return InkWell(
      onTap: _onClickFoto,
      child: _file != null
          ? Image.file(
              _file,
              height: 150,
            )
          : Image.asset(
              "assets/images/camera.png",
              height: 150,
            ),
    );
  }

  void _onClickFoto() async {
    File file = await ImagePicker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        this._file = file;
      });
    }
    FirebaseService.uploadFirebaseStorage(file);
  }
}
