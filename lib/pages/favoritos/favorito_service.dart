import 'dart:io';

import 'package:carros/main.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carro_dao.dart';
import 'package:carros/pages/favoritos/favorito.dart';
import 'package:carros/pages/favoritos/favorito_dao.dart';
import 'package:carros/pages/favoritos/favoritos_bloc.dart';
import 'package:provider/provider.dart';

class FavoritoService {
  static Future<bool> favoritar(context, Carro c) async{

    Favorito f = Favorito.fromCarro(c);

    final dao = FavoritoDAO();

    final exists = await dao.exists(c.id);

    if (exists) {
      // remove dos favoritos
      dao.delete(c.id);

      Provider.of<FavoritosBloc>(context).fetch();

      return false;
    } else {
      // adiciona nos favoritos
      dao.save(f);

      Provider.of<FavoritosBloc>(context).fetch();

      return true;
    }
  }

  static Future<List<Carro>> getCarros() async{
    List<Carro> carros = await CarroDAO().query("select * from carro c, favorito f  where c.id = f.id");

    return carros;
  }
}