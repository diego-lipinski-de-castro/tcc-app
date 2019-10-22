import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService _authService = AuthService();

  TextEditingController _phoneField = TextEditingController();
  TextEditingController _smsCodeField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          ConnectionState state = snapshot.connectionState;
          bool loggedIn = _authService.user != null;
          FirebaseUser user = _authService.user;
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
                              await showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      title:
                                          Text("Insira o número do telefone"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          TextField(
                                            controller: _phoneField,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder()),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(top: 10.0),
                                            child: RaisedButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext)
                                                    .pop();
                                              },
                                              child: Text("Enviar SMS"),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  });

                              if (_phoneField.text != null &&
                                  _phoneField.text.trim().length > 0) {
                                bool hasSent = await _authService
                                    .verifyPhone(_phoneField.text);

                                if (hasSent != null) {
                                  showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          title: Text(
                                              "Insira o código que você recebeu via SMS"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              TextField(
                                                controller: _smsCodeField,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder()),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(top: 10.0),
                                                child: RaisedButton(
                                                  onPressed: () async {
                                                    bool success =
                                                        await _authService
                                                            .confirmPhone(
                                                                _smsCodeField
                                                                    .text);

                                                    Navigator.of(dialogContext)
                                                        .pop();

                                                    _phoneField.text = '';
                                                    _smsCodeField.text = '';

                                                    if (success) {
                                                      Scaffold.of(context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Número de telefone verificado!')));
                                                    } else {
                                                      Scaffold.of(context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Falha ao verificar número de telefone :(')));
                                                    }
                                                  },
                                                  child: Text("Confirmar"),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          'Falha ao enviar código SMS :(')));
                                }
                              }
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              _authService.googleSignOut();
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
