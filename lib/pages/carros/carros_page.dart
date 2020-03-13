import 'dart:async';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_listview.dart';
import 'package:carros/pages/carros/carros_model.dart';
import 'package:carros/utils/event_bus.dart';
import 'package:carros/widgets/text_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class CarrosPage extends StatefulWidget {
  String tipo;

  CarrosPage(this.tipo);

  @override
  _CarrosPageState createState() => _CarrosPageState();
}

class _CarrosPageState extends State<CarrosPage>
    with AutomaticKeepAliveClientMixin<CarrosPage> {
  List<Carro> carros;

  final _model = CarrosModel();

  String get tipo => widget.tipo;

  StreamSubscription<Event> subscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _fetch();

    // Escutando uma stream
    final bus = EventBus.get(context);
    subscription = bus.stream.listen((Event e) {
      print("Event $e");
      CarroEvent carroEvent = e;
      if (carroEvent.tipo == tipo) {
        _fetch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Observer(
      builder: (_) {
        List<Carro> carros = _model.carros;

        if (_model.error != null) {
          return TextError(
            "Não foi possível buscar os carros \n\n  clique aqui para tentar novamente",
            onPressed: _fetch,
          );
        }

        if (carros == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CarrosListView(carros),
        );
      },
    );
  }

  Future<void> _onRefresh() {
    return _fetch();
  }

  @override
  void dispose() {
    subscription.cancel();
  }

  _fetch() {
    _model.fetch(widget.tipo);
  }
}
