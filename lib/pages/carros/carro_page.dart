import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carro_form_page.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/pages/carros/loripsum_api.dart';
import 'package:carros/pages/carros/mapa_page.dart';
import 'package:carros/pages/carros/video_page.dart';
import 'package:carros/pages/favoritos/favorito_service.dart';
import 'package:carros/pages/favoritos/favoritos_bloc.dart';
import 'package:carros/utils/alert.dart';
import 'package:carros/utils/event_bus.dart';
import 'package:carros/utils/nav.dart';
import 'package:carros/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class CarroPage extends StatefulWidget {
  Carro carro;

  CarroPage(this.carro);

  @override
  _CarroPageState createState() => _CarroPageState();
}

class _CarroPageState extends State<CarroPage> {
  final _loripsumApiBloc = LoripsumBloc();

  final _favoritoBloc = FavoritosBloc();

  Carro get carro => widget.carro;

  Color color = Colors.grey;

  @override
  void initState() {
    super.initState();

    _loripsumApiBloc.fetch();

    //_favoritoBloc.isFavorito(carro);
    FavoritoService().isFavorito(carro).then((bool favorito) {
      setState(() {
        color = favorito ? Colors.red : Colors.grey;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.carro.nome),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.place),
            onPressed: () {
              _onClickMapa();
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {
              _onClickVideo();
            },
          ),
          PopupMenuButton<String>(
            onSelected: _onClickPopupMenu,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: "Editar",
                  child: Text("Editar"),
                ),
                PopupMenuItem(
                  value: "Deletar",
                  child: Text("Deletar"),
                ),
                PopupMenuItem(
                  value: "Share",
                  child: Text("Share"),
                )
              ];
            },
          )
        ],
      ),
      body: _body(),
    );
  }

  _body() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: carro.urlFoto ??
                "http://www.livroandroid.com.br/livro/carros/classicos/Chevrolet_Impala_Coupe.png",
          ),
          _bloco1(),
          Divider(),
          _bloco2(),
        ],
      ),
    );
  }

  Row _bloco1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              text(widget.carro.nome, fontSize: 20, bold: true),
              text(widget.carro.tipo, fontSize: 16)
            ],
          ),
        ),
        Row(
          children: <Widget>[
           /* StreamBuilder(
              stream: _favoritoBloc.streamIsFavorito,
              initialData: false,
              builder: (context, snapshot) {
                return IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: snapshot.data ? Colors.red : Colors.grey,
                    size: 40,
                  ),
                  onPressed: _onClickFavorito,
                );
              },
            )*/
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: color,
                size: 40,
              ),
              onPressed: _onClickFavorito,
            ),
            IconButton(
              icon: Icon(
                Icons.share,
                size: 40,
              ),
              onPressed: _onClickShare,
            )
          ],
        )
      ],
    );
  }

  _bloco2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        text(widget.carro.descricao, fontSize: 16, bold: true),
        SizedBox(
          height: 20,
        ),
        StreamBuilder<String>(
          stream: _loripsumApiBloc.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return text(snapshot.data, fontSize: 16);
          },
        ),
      ],
    );
  }

  void _onClickMapa() {
    print("> carro Mapa");
    if (carro.latitude != null && carro.longitude != null) {
      push(context, MapaPage(carro));
    } else {
      alert(context,
          "Erro : Este carro não possui nenhuma latitude/longitude.");
    }
  }

  void _onClickVideo() {
    print("> carro video");
    if (carro.urlVideo != null && carro.urlVideo.isNotEmpty) {
      //launch(carro.urlVideo);
      push(context, VideoPage(carro));
    } else {
      alert(context,
          "Erro : Este carro não possui nenhum vídeo");
    }
  }

  _onClickPopupMenu(String value) {
    switch (value) {
      case "Editar":
        push(context, CarroFormPage(carro: carro));
        break;
      case "Deletar":
        deletar();
        break;
      case "Share":
        print("Share !!!");
        break;
    }
  }

  void _onClickFavorito() async {
    bool favorito = await FavoritoService().favoritar(carro);

    setState(() {
      //_favoritoBloc.isFavorito(carro);
      color = favorito ? Colors.red : Colors.grey;

      print(favorito);
    });
  }

  void _onClickShare() {


  }

  deletar() async {
    ApiResponse<bool> response = await CarrosApi.delete(carro);

    if (response.ok) {
      alert(context, response.msg, callback: () {
        //    EventBus.get(context).sendEvent(CarroEvent("carro_salvo",c.tipo));
        EventBus.get(context).sendEvent(
            CarroEvent("carro_deletado", carro.tipo));
        pop(context);
      });
    } else {
      alert(context, response.msg);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _loripsumApiBloc.dispose();
    _favoritoBloc.dispose();
  }
}
