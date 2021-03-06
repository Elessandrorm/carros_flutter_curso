import 'dart:async';

import 'package:carros/main.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_listview.dart';
import 'package:carros/pages/favoritos/favoritos_bloc.dart';
import 'package:carros/widgets/text_error.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carros/pages/favoritos/favorito_service.dart';

class FavoritosPage extends StatefulWidget {
  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage>
    with AutomaticKeepAliveClientMixin<FavoritosPage> {

  List<Carro> carros;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
//    FavoritosBloc favoritosBloc = Provider.of<FavoritosBloc>(context, listen: false);
//    favoritosBloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FavoritoService().stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return TextError("Não foi possível buscar os carros");
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Carro> carros = snapshot.data.documents.map((DocumentSnapshot document) {
          return new Carro.fromMap(document.data);
        }).toList();

        return CarrosListView(carros);
      },
    );


/*    FavoritosBloc favoritosBloc = Provider.of<FavoritosBloc>(context, listen: false);

    return StreamBuilder(
      stream: favoritosBloc.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return TextError("Não foi possível buscar os carros");
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Carro> carros = snapshot.data;

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CarrosListView(carros),
        );
      },
    );*/
  }

  /*Future<void> _onRefresh() {
    return Provider.of<FavoritosBloc>(context, listen: false).fetch();
  } */
}
