import 'dart:async';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/pages/carros/carro_dao.dart';
import 'package:carros/utils/network.dart';
import 'package:mobx/mobx.dart';

part 'carros_model.g.dart';

class CarrosModel = CarrosModelBase with _$CarrosModel;

abstract class CarrosModelBase with Store {

  @observable
  List<Carro> carros;

  @observable
  Exception error;

  @action
  fetch(String tipo) async {
    try {
      bool networkOn = await isNetworkOn();
      this.error = null;

      if (!networkOn) {
        print("não tem internet");
        this.carros = await CarroDAO().findAllByTipo(tipo);
      }

      this.carros = await CarrosApi.getCarros(tipo);

      if (!this.carros.isEmpty) {
        final dao = CarroDAO();

        // Salver todos os carrps mp banco de dados
        this.carros.forEach(dao.save);
      }
    } catch (e) {
      print(e);
      this.error = e;
    }
  }
}