import 'dart:io';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carro_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carros/firebase/firebase_service.dart';

class FavoritoService {

  //CollectionReference get _carros => Firestore.instance.collection('carros');

  CollectionReference get _users => Firestore.instance.collection('users');

  CollectionReference get _carros => _users.document(firebaseUserUid).collection('carros');

  Stream<QuerySnapshot> get stream => _carros.snapshots();

  Future<bool> favoritar(Carro c) async{

    //Favorito f = Favorito.fromCarro(c);
    //final dao = FavoritoDAO();
    //final exists = await dao.exists(c.id);
    DocumentReference docRef = _carros.document("${c.id}");

    DocumentSnapshot doc = await docRef.get();

    final exists = doc.exists;

    if (exists) {
      // remove dos favoritos
      //dao.delete(c.id);
      //Provider.of<FavoritosBloc>(context).fetch();

      docRef.delete();

      return false;
    } else {
      // adiciona nos favoritos
      //dao.save(f);
      //Provider.of<FavoritosBloc>(context).fetch();
      docRef.setData(c.toMap());

      return true;
    }

  }

  static Future<List<Carro>> getCarros() async{
    List<Carro> carros = await CarroDAO().query("select * from carro c, favorito f  where c.id = f.id");

    return carros;
  }

  Future<bool> isFavorito(Carro c) async {

//    bool exists = await dao.exists(c.id);
    DocumentReference docRef = _carros.document("${c.id}");

    DocumentSnapshot doc = await docRef.get();

    final exists = doc.exists;

    return exists;
  }

  Future<bool> deletaCarros() async{
    print("Delete carros do usuário logado: $firebaseUserUid");

    final query = await _carros.getDocuments();

    for (DocumentSnapshot doc in query.documents) {
      await doc.reference.delete();
    }

    _users.document(firebaseUserUid).delete();
  }
}