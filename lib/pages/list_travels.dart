import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tcc/services/auth.dart';
import '../models/travel.dart';
import '../services/Travel.dart';

class ListTravelPage extends StatefulWidget {
  ListTravelPage({Key key}) : super(key: key);

  _ListTravelPageState createState() => _ListTravelPageState();
}

class _ListTravelPageState extends State<ListTravelPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  TravelService _travelService = TravelService();

  AuthService _authService = AuthService.singleton();
  FirebaseUser _user;

  bool _loading = false;

  List<Travel> _results = [];

  @override
  void initState() {
    super.initState();

    getUser().then((_) => _refresh(init: true));
  }

  Future<void> getUser() async {
    setState(() {
      _loading = true;
    });
    FirebaseUser user = await _authService.currentUser();

    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _refresh({init = false}) async {
    if (init) {
      setState(() {
        _loading = true;
      });
    }

    List<Travel> results = await _travelService.getAllByUser();

    setState(() {
      _results = results;
      if (init) {
        _loading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loggedIn = _user != null;
    bool isPhoneVerified = _user?.phoneNumber != null;

    return Scaffold(
      appBar: AppBar(
        title: Text("Suas excursões"),
      ),
      body: Stack(
        children: <Widget>[
          if (_loading) ...[
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
          if (!_loading && !loggedIn) ...[
            Center(
              child: Text("Você não está autenticado."),
            ),
          ],
          if (!_loading && loggedIn) ...[
            if (_results.length == 0) ...[
              Center(
                child: Text("Você não possui nenhuma excursão cadastrada."),
              )
            ] else ...[
              RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 75.0),
                    child: ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (itemContext, index) {
                          return GestureDetector(
                            onLongPress: () {
                              if (Platform.isIOS) {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (cupertinoDialogContext) {
                                      return CupertinoAlertDialog(
                                        title: Text('Confirmar'),
                                        content: Text(
                                            'Tem certeza que deseja apagar a excursão ' +
                                                _results
                                                    .elementAt(index)
                                                    ?.title +
                                                '?'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.of(
                                                      cupertinoDialogContext)
                                                  .pop();
                                            },
                                            child: Text('Não'),
                                          ),
                                          CupertinoDialogAction(
                                            onPressed: () async {
                                              await _travelService.delete(
                                                  _results
                                                      .elementAt(index)
                                                      ?.id);

                                              Navigator.of(
                                                      cupertinoDialogContext)
                                                  .pop();

                                              setState(() {});

                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Excursão apagada.')));
                                            },
                                            child: Text('Sim'),
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: Text('Confirmar'),
                                        content: Text(
                                            'Tem certeza que deseja apagar a excursão ' +
                                                _results
                                                    .elementAt(index)
                                                    ?.title +
                                                '?'),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Não'),
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                            },
                                          ),
                                          FlatButton(
                                            child: Text('Sim'),
                                            onPressed: () async {
                                              await _travelService.delete(
                                                  _results
                                                      .elementAt(index)
                                                      ?.id);

                                              Navigator.of(dialogContext).pop();

                                              setState(() {});

                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Excursão apagada.')));
                                            },
                                          )
                                        ],
                                      );
                                    });
                              }
                            },
                            child: Container(
                                margin: EdgeInsets.only(
                                    top: 15.0,
                                    left: 15.0,
                                    right: 15.0,
                                    bottom: index + 1 == _results.length
                                        ? 30.0
                                        : 0),
                                padding: EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _results.elementAt(index)?.title,
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.5),
                                            ),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                height: 2.0,
                                                width: 18.0,
                                                color: Color(0xff00c6ff)),
                                            RichText(
                                              overflow: TextOverflow.fade,
                                              softWrap: true,
                                              maxLines: 2,
                                              text: TextSpan(
                                                style: TextStyle(
                                                    color: Color(0xffb6b2df),
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                children: <TextSpan>[
                                                  TextSpan(text: "Saída de "),
                                                  TextSpan(
                                                      text: _results
                                                          .elementAt(index)
                                                          ?.start,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              ),
                                            ),
                                          ]),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                    ),
                                    Text(
                                        "R\$" +
                                            _results.elementAt(index)?.price,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.5))
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10.0,
                                      offset: Offset(0.0, 10.0),
                                    ),
                                  ],
                                )),
                          );
                        }),
                  ))
            ]
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            if (isPhoneVerified) {
              Navigator.pushNamed(context, '/add-travel');
            } else {
              showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      content: Text(
                          "Você precisa verificar um número de telefone para poder cadastrar excursões."),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Voltar"),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        FlatButton(
                          child: Text("Verificar"),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await Navigator.pushNamed(context, '/profile');

                            getUser();
                          },
                        )
                      ],
                    );
                  });
            }
          }),
    );
  }
}
