import 'package:carros/pages/carros/home_page.dart';
import 'package:carros/pages/login/login_page.dart';
import 'package:carros/utils/nav.dart';
import 'package:carros/utils/sql/db_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pages/login/usuario.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

//    Future.delayed(Duration(seconds:10), () {
//      push(context, LoginPage());
//    });
    Future futureA = DatabaseHelper.getInstance().db;

    Future futureB = Future.delayed(Duration(seconds: 3));

    //Future<Usuario> futureC = Usuario.get();
    Future<FirebaseUser> futureC = FirebaseAuth.instance.currentUser();

//    Future.then((Usuario user){
//      if (user != null) {
//        push(context, HomePage(), replace: true);
//      }
//    });

    Future.wait([futureA, futureB, futureC]).then((List values) {
      FirebaseUser user = values[2];
      print(user);

      if (user != null) {
        push(context, HomePage(), replace: true);
      } else {
        push(context, LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[200],
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
