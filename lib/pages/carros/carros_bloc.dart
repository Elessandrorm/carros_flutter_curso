import 'dart:async';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/pages/carros/carro_dao.dart';
import 'package:carros/utils/network.dart';

class CarrosBloc {
  final _streamController = StreamController<List<Carro>>();

  Stream<List<Carro>> get stream => _streamController.stream;

  Future<List<Carro>> fetch(String tipo) async {
    try {
      bool networkOn = await isNetworkOn();

      if (!networkOn) {
        print("não tem internet");
        List<Carro> carros = await CarroDAO().findAllByTipo(tipo);
        if (!_streamController.isClosed) {
          _streamController.add(carros);
        }
        return carros;
      }

      List<Carro> carros = await CarrosApi.getCarros(tipo);

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