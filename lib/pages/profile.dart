import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc/home.dart';
import '../services/auth.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService _authService = AuthService.singleton();

  TextEditingController _phoneField = TextEditingController();
  TextEditingController _smsCodeField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
          stream: AuthService.userStream,
          builder: (context, snapshot) {
            ConnectionState state = snapshot.connectionState;
            bool loggedIn = AuthService.user != null;
            FirebaseUser user = AuthService.user;
            bool isPhoneVerified = user?.phoneNumber != null;

            if (state == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!loggedIn) {
              return Container();
            }

            return Scaffold(
                appBar: AppBar(
                  title: Text("Perfil"),
                ),
                body: Builder(
                  builder: (context) => Container(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text(user.displayName),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text(user.email),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.photoUrl),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            onPressed: () async {
                              if (isPhoneVerified) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text("Número verificado: " +
                                        user.phoneNumber)));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FirstStep()));
                              }
                            },
                            child: Row(
                              mainAxisAlignment: isPhoneVerified
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.center,
                              children: <Widget>[
                                Text(isPhoneVerified
                                    ? "Número de telefone verificado"
                                    : "Verificar número de telefone"),
                                if (isPhoneVerified) ...[
                                  Icon(Icons.check_circle, color: Colors.green),
                                ]
                              ],
                            ),
                            padding: EdgeInsets.all(15.0),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            width: MediaQuery.of(context).size.width,
                            child: RaisedButton(
                              onPressed: () async {
                                await _authService.googleSignOut();
                                Navigator.of(context).pop();
                              },
                              child: Text("Sair"),
                              padding: EdgeInsets.all(15.0),
                            ))
                      ],
                    ),
                  ),
                ));
          });
  }
}

class FirstStep extends StatefulWidget {
  FirstStep({Key key}) : super(key: key);

  @override
  _FirstStepState createState() => _FirstStepState();
}

class _FirstStepState extends State<FirstStep> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AuthService _authService = AuthService.singleton();

  TextEditingController _phoneField = TextEditingController();

  _sendSMS() async {
    if (_phoneField.text.trim().length >= 10) {
      bool hasSent = await _authService.verifyPhone(_phoneField.text);

      if (hasSent) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondStep()));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Erro ao verificar número de telefone")));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Insira um número de telefone válido")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Verificar telefone"),
      ),
      body: Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _phoneField,
              autocorrect: false,
              autofocus: true,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Número do telefone com DDD",
              ),
              onSubmitted: (value) {
                _sendSMS();
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendSMS,
        child: Icon(Icons.chevron_right),
      ),
    );
  }
}

class SecondStep extends StatefulWidget {
  SecondStep({Key key}) : super(key: key);

  @override
  _SecondStepState createState() => _SecondStepState();
}

class _SecondStepState extends State<SecondStep> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AuthService _authService = AuthService.singleton();

  TextEditingController _smsCodeField = TextEditingController();

  _getCode() async {
    if (_smsCodeField.text.trim().length > 0) {
      bool success = await _authService.confirmPhone(_smsCodeField.text);

      if (success) {
        Navigator.of(context).popUntil((route) {
          return route.settings.name == '/profile';
        });
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Erro ao confirmar número de telefone")));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Insira o código que você recebeu via SMS")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Verificar telefone"),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: TextField(
          controller: _smsCodeField,
          autocorrect: false,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Código SMS",
          ),
          onSubmitted: (value) {
            _getCode();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCode,
        child: Icon(Icons.check),
      ),
    );
  }
}