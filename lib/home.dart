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
  AuthService _authService;
  TextEditingController _queryFieldController;
  FocusNode _queryFieldFocus;
  bool _queryFieldHasFocus = false;
  double _topContainerHeight;

  @override
  void initState() {
    super.initState();

    _authService = AuthService();
    _queryFieldController = TextEditingController();
    _queryFieldFocus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    _queryFieldFocus.dispose();
  }

  void _updateQueryFieldFocus([bool focus = true]) {
    if (!focus) {
      _queryFieldFocus.unfocus();
    }
    setState(() {
      _queryFieldHasFocus = focus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppBar appBar = AppBar(
        elevation: 0,
        leading: _queryFieldHasFocus
            ? IconButton(
                onPressed: () {
                  _updateQueryFieldFocus(false);
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              )
            : null);

    _topContainerHeight =
        _queryFieldHasFocus ? 0 : MediaQuery.of(context).size.height / 1.75;

    final button = Align(
      alignment: FractionalOffset.bottomCenter,
      child: FlatButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddTravelPage()));
          },
          color: Colors.deepPurple.shade400,
          highlightColor: Colors.deepPurple.shade400,
          splashColor: Colors.deepPurple,
          padding: EdgeInsets.all(20.0),
          child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Criar uma excursão',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.add, color: Colors.white)
                ],
              ))),
    );

    return StreamBuilder<FirebaseUser>(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          ConnectionState state = snapshot.connectionState;
          bool loggedIn = _authService.user != null;

          return Scaffold(
            appBar: appBar,
            body: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  AnimatedContainer(
                      duration: Duration(milliseconds: 1500),
                      height: _topContainerHeight,
                      width: double.infinity,
                      color: Colors.deepPurple,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          if (!_queryFieldHasFocus) ...[
                                            button,
                                          ],
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
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextField(
                          controller: _queryFieldController,
                          focusNode: _queryFieldFocus,
                          onTap: _updateQueryFieldFocus,
                          style: TextStyle(fontSize: 20.0),
                          decoration: InputDecoration(
                              hintText: 'Para qual evento deseja ir?'),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
