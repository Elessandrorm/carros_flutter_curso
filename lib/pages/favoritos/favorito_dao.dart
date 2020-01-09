import 'package:carros/utils/sql/base_dao.dart';
import 'package:carros/pages/favoritos/favorito.dart';

class FavoritoDAO extends BaseDAO<Favorito> {

  @override
  // TODO: implement tableName
  String get tableName => "favorito";

  @override
  Favorito fromMap(Map<String, dynamic> map) {
    return Favorito.fromMap(map);
  }

}