import 'dart:convert' as convert;
import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carro_dao.dart';
import 'package:carros/pages/login/usuario.dart';
import 'package:http/http.dart' as http;

class TipoCarro {
  static final String classicos = "classicos";
  static final String esportivos = "esportivos";
  static final String luxo = "luxo";
}

class CarrosApi {
  static Future<List<Carro>> getCarros(String tipo) async {

    Usuario user = await Usuario.get();

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${user.token}"
    };

    var url = 'https://carros-springboot.herokuapp.com/api/v2/carros/tipo/$tipo';

    print("GET > $url");

    var response = await http.get(url, headers: headers);
    String json = response.body;
    //print("status code: ${response.statusCode}");
    //print(json);

    List list = convert.json.decode(json);

    List<Carro> carros = list.map<Carro>((map) => Carro.fromMap(map)).toList();

    return carros;
  }

  static Future<ApiResponse<bool>> save(Carro c) async {
    try {
      Usuario user = await Usuario.get();

      Map<String, String> headers = {
        "content-type":"application/json",
        "Authorization":"Bearer ${user.token}"
      };

      var url = 'http://carros-springboot.herokuapp.com/api/v2/carros';

      if (c.id != null) {
        url += "/${c.id}";
      }

      print("POST > $url");

      String json = c.toJson();

      var response = await (c.id == null
         ? http.post(url, body: json, headers: headers)
         : http.put(url, body: json, headers: headers)
      );

      Map mapResponse = convert.json.decode(response.body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Carro carro = Carro.fromMap(mapResponse);

        print("'Novo carro: ${carro.id}");

        return ApiResponse.ok(true);
      }

      if (response.body == null || response.body.isEmpty) {
        return ApiResponse.error("Não foi possível salvar o carro");
      }

      return ApiResponse.error(mapResponse["error"]);
    } on Exception catch (e) {
      print(e);
      return ApiResponse.error("Não foi possível salvar o carro");
    }
  }
}

