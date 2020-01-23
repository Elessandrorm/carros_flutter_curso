import 'dart:async';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carro_dao.dart';
import 'package:carros/pages/favoritos/favorito_dao.dart';
import 'package:carros/pages/favoritos/favorito_service.dart';

class FavoritosBloc {
  final _streamController = StreamController<List<Carro>>();

  final _streamIsFavorito = StreamController<bool>();

  Stream<List<Carro>> get stream => _streamController.stream;

  Stream<bool> get streamIsFavorito => _streamIsFavorito.stream;

  Future<List<Carro>> fetch() async {
    try {
      List<Carro> carros = await FavoritoService.getCarros();

      if (!carros.isEmpty) {
        final dao = CarroDAO();
        // Salver todos os carrps mp banco de dados
        carros.forEach(dao.save);
      }

      if (!_streamController.isClosed) {
        _streamController.add(carros);
      }
      return carros;
    } catch (e) {
      print(e);
      _streamController.addError(e);
    }
  }

  Future<bool> isFavorito(Carro c) async{
    try {
      final dao = FavoritoDAO();

      final exists = await dao.exists(c.id);

      if (!_streamIsFavorito.isClosed) {
        _streamIsFavorito.add(exists);
      }
      return exists;
    } on Exception catch (e) {
      print(e);
      _streamIsFavorito.addError(e);
    }
  }

  void dispose() {
    _streamController.close();
    _streamIsFavorito.close();
  }
}