import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc/pages/edit_travel.dart';
import 'package:tcc/services/auth.dart';
import 'add_travel.dart';
import '../models/Travel.dart';
import '../services/Travel.dart';

class ListTravelPage extends StatefulWidget {
  ListTravelPage({Key key}) : super(key: key);

  _ListTravelPageState createState() => _ListTravelPageState();
}

class _ListTravelPageState extends State<ListTravelPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  TravelService _travelService = TravelService();
  AuthService _authService = AuthService();

  List<Travel> _results = [];

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    List<Travel> results = await _travelService.getAllByUser();

    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suas excursões"),
      ),
      body: StreamBuilder<FirebaseUser>(
          stream: _authService.userStream,
          builder: (streamContext, snapshot) {
            ConnectionState state = snapshot.connectionState;
            bool loggedIn = _authService.user != null;

            if (state == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!loggedIn) {
              return Container();
            }

            return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (dialogContext, index) {
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Confirmar"),
                                  content: Text(
                                      "Tem certeza que deseja apagar a excursão " +
                                          _results.elementAt(index)?.title +
                                          "?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Não"),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("Sim"),
                                      onPressed: () async {
                                        await _travelService.delete(
                                            _results.elementAt(index)?.id);

                                        Navigator.of(dialogContext).pop();

                                        setState(() {});

                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Excursão apagada.')));
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => EditTravelPage(
                          //               docID: _results.elementAt(index)?.id,
                          //             )));
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 15.0,
                                left: 15.0,
                                right: 15.0,
                                bottom:
                                    index + 1 == _results.length ? 30.0 : 0),
                            padding: EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                fontWeight: FontWeight.w400),
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
                                Text("R\$" + _results.elementAt(index)?.price,
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
                    }));
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddTravelPage()));
          }),
    );
  }
}
