import 'package:flutter/material.dart';

Future push(BuildContext context, Widget page, {bool replace = false} ){

  if (replace) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) {
      return page;
    }));
  } else {
    return Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) {
      return page;
    }));
  }
}

pop(BuildContext context, {String str}) {
  return Navigator.pop(context, str);
}

