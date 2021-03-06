import 'dart:convert' as convert;
import 'dart:io';
import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/upload_api.dart';
import 'package:carros/utils/http_helper.dart' as http;

class TipoCarro {
  static final String classicos = "classicos";
  static final String esportivos = "esportivos";
  static final String luxo = "luxo";
}

class CarrosApi {
  static Future<List<Carro>> getCarros(String tipo) async {

    var url = 'https://carros-springboot.herokuapp.com/api/v1/carros/tipo/$tipo';

    print("GET > $url");

    var response = await http.get(url);

    String json = response.body;
    //print("status code: ${response.statusCode}");
    //print(json);

    List list = convert.json.decode(json);

    List<Carro> carros = list.map<Carro>((map) => Carro.fromMap(map)).toList();

    return carros;
  }

  static Future<ApiResponse<bool>> save(Carro c, File file) async {
    try {
      if (file != null) {
        ApiResponse<String> response = await UploadApi.upload(file);
        if (response.ok) {
          String urlFoto = response.result;
          c.urlFoto = urlFoto;
        }
      }
      var url = 'http://carros-springboot.herokuapp.com/api/v1/carros';

      if (c.id != null) {
        url += "/${c.id}";
      }

      print("POST > $url");

      String json = c.toJson();

      var response = await (c.id == null
         ? http.post(url, body: json)
         : http.put(url, body: json)
      );

      Map mapResponse = convert.json.decode(response.body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Carro carro = Carro.fromMap(mapResponse);

        print("'Novo carro: ${carro.id}");

        return ApiResponse.ok();
      }

      if (response.body == null || response.body.isEmpty) {
        return ApiResponse.error(msg:"Não foi possível salvar o carro");
      }

      return ApiResponse.error(msg: mapResponse["error"]);
    } on Exception catch (e) {
      print(e);
      return ApiResponse.error(msg: "Não foi possível salvar o carro");
    }
  }

  static delete(Carro c) async {
    try {

      var url = 'http://carros-springboot.herokuapp.com/api/v1/carros/${c.id}';

      print("DELETE > $url");

      var response = await http.delete(url);

      Map mapResponse = convert.json.decode(response.body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return ApiResponse.ok(msg: mapResponse['msg']);
      }
      return ApiResponse.error(msg: "Não foi possível deletar o carro!");
    } catch (e) {
      print(e);
      return ApiResponse.error(msg: "Não foi possível deletar o carro!");
    }
  }
}

