import 'dart:async';

import 'package:carros/cadastro/cadastro_page.dart';
import 'package:carros/firebase.dart';
import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/carros/home_page.dart';
import 'package:carros/pages/login/login_bloc.dart';
import 'package:carros/pages/login/usuario.dart';
import 'package:carros/utils/alert.dart';
import 'package:carros/utils/nav.dart';
import 'package:carros/widgets/app_button.dart';
import 'package:carros/widgets/app_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final tLogin = TextEditingController();

  final tSenha = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _focusSenha = FocusNode();

  final bloc = LoginBloc();

  @override
  void initState() {
    super.initState();

    // Firebase Cloud Message - iniciando
    initFcm();

    // Firebase Remote config
    _firebaseRemoteConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carros"),
      ),
      body: _body(),
    );
  }

  _body() {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            AppText(
              "Login",
              "Digite o login",
              controller: tLogin,
              validator: _validateLogin,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              nextFocus: _focusSenha,
            ),
            SizedBox(
              height: 10,
            ),
            AppText(
              "Senha",
              "Digite a senha",
              password: true,
              controller: tSenha,
              validator: _validateSenha,
              keyboardType: TextInputType.number,
              focusNode: _focusSenha,
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder<bool>(
                stream: bloc.streamLoginButton,
                initialData: false,
                builder: (context, snapshot) {
                  return AppButton(
                    "Login",
                    onPressed: _onClickLogin,
                    showProgress: snapshot.data,
                  );
                }),
            Container(
              height: 46,
              margin: EdgeInsets.only(top: 20),
              child: GoogleSignInButton(
                onPressed: _onClickGoogle,
                text: "Autenticar com o Google",
              ),
            ),
            Container(
              height: 46,
              margin: EdgeInsets.only(top: 20),
              child: InkWell(
                onTap: _onClickCadastrar,
                child: Text(
                  "Cadastre-se",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onClickLogin() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    String login = tLogin.text;
    String senha = tSenha.text;

    print("Login $login, $senha");

    ApiResponse response = await bloc.login(login, senha);

    if (response.ok) {
//      Usuario user = response.result;
      // print(">>> $user");

      push(context, HomePage(), replace: true);
    } else {
      alert(context, response.msg);
    }
  }

  String _validateLogin(String text) {
    if (text.isEmpty) {
      return "Digite o login";
    }
    return null;
  }

  String _validateSenha(String text) {
    if (text.isEmpty) {
      return "Digite a senha";
    }
    if (text.length < 3) {
      return "A senha precisa ter pelo menos 3 caracteres";
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();

    bloc.dispose();
  }

  void _onClickGoogle() async {
    final service = FirebaseService();
    ApiResponse response = await service.loginGoogle();

    if (response.ok) {
      push(context, HomePage(), replace: true);
    } else {
      alert(context, response.msg);
    }
  }

  void _onClickCadastrar() {
    push(context, CadastroPage(), replace: true);
  }

  void _firebaseRemoteConfig() {
    RemoteConfig.instance.then((remoteConfig) {
      remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));

      try {
        // Aplicativo em produção precisa ficar = 5 horas
        remoteConfig.fetch(expiration: const Duration(minutes: 1));
        remoteConfig.activateFetched();
      } catch (error) {
        print("Remote config: $error");
      }
      final mensagem = remoteConfig.getString("mensagem");

      print("'Mensagem: $mensagem");
    });
  }
}
