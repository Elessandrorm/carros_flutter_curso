import 'dart:async';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/pages/carros/carro_dao.dart';
import 'package:carros/pages/favoritos/favorito_service.dart';
import 'package:carros/utils/network.dart';

class FavoritosBloc {
  final _streamController = StreamController<List<Carro>>();

  Stream<List<Carro>> get stream => _streamController.stream;

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
  void dispose() {
    _streamController.close();
  }
}