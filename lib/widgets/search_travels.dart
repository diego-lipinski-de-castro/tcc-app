import 'dart:async';

import 'package:flutter/material.dart';
import '../services/travel.dart';
import '../models/Travel.dart';

class SearchTravels extends StatefulWidget {
  SearchTravels({Key key}) : super(key: key);

  _SearchTravelsState createState() => _SearchTravelsState();
}

class _SearchTravelsState extends State<SearchTravels> {
  TravelService _travelService = TravelService();

  TextEditingController queryController = TextEditingController();
  FocusNode queryFocus = FocusNode();
  Timer _debounce;

  List<Travel> _results = [];

  Future<List<Travel>> _search(text) async {
    try {
      List travels = await _travelService.search(text);
      return travels;
    } catch (error) {
      print(error);
      return [];
    }
  }

  void _handleSearch(String text) {
    _search(text).then((travels) {
      setState(() {
        _results = travels;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
      primaryColor: Colors.white,
      primaryIconTheme:
          Theme.of(context).primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: Theme.of(context).textTheme,
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          iconTheme: theme.primaryIconTheme,
          brightness: theme.primaryColorBrightness,
          title: TextField(
            controller: queryController,
            focusNode: queryFocus,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            autocorrect: false,
            autofocus: true,
            onChanged: (text) {
              if (text.length < 3) return;

              if (_debounce?.isActive ?? false) _debounce.cancel();

              _debounce = Timer(Duration(milliseconds: 600), () {
                _handleSearch(text);
              });
            },
            onSubmitted: (text) {
              _handleSearch(text);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Pesquise pelo nome do evento",
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                queryController.clear();
              },
            )
          ],
        ),
        body: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, _results.elementAt(index));
                },
                child: Container(
                    margin: EdgeInsets.only(
                        top: 15.0,
                        left: 15.0,
                        right: 15.0,
                        bottom: index + 1 == _results.length ? 30.0 : 0),
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _results.elementAt(index)?.title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  height: 2.0,
                                  width: 18.0,
                                  color: Color(0xff00c6ff)),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      color: Color(0xffb6b2df),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400),
                                  children: <TextSpan>[
                                    TextSpan(text: "Saída de "),
                                    TextSpan(
                                        text: _results.elementAt(index)?.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ]),
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
  }
}
