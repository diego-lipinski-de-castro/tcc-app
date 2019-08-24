import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/auth.dart';
import 'pages/addTravel.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          ConnectionState state = snapshot.connectionState;
          bool loggedIn = _authService.user != null;

          return Scaffold(
            body: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Container(
                      color: Colors.deepPurple,
                      height: MediaQuery.of(context).size.height / 1.75,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (state == ConnectionState.waiting) ...[
                            CircularProgressIndicator()
                          ] else ...[
                            if (!loggedIn) ...[
                              Expanded(
                                child: RawMaterialButton(
                                  onPressed: _authService.googleSignIn,
                                  padding: EdgeInsets.all(50.0),
                                  child: Text(
                                    'Clique aqui para iniciar uma conta e criar excursões',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24.0),
                                  ),
                                ),
                              )
                            ] else ...[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      color: Colors.deepPurple,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Align(
                                              alignment: FractionalOffset.bottomCenter,
                                            child: FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTravelPage()));
                                                },
                                                color: Colors.deepPurple.shade400,
                                                highlightColor:
                                                Colors.deepPurple.shade400,
                                                splashColor: Colors.deepPurple,
                                                padding: EdgeInsets.all(20.0),
                                                child: SizedBox(
                                                    width: double.infinity,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          'Criar uma excursão',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                              FontWeight.w600),
                                                        ),
                                                        Icon(Icons.add,
                                                            color: Colors.white)
                                                      ],
                                                    ))),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextField(
                      style: TextStyle(fontSize: 20.0),
                      decoration: InputDecoration(
                          hintText: 'Para qual evento deseja ir?'),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}