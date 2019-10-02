import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class SearchPlacesPage extends StatefulWidget {
  SearchPlacesPage({Key key}) : super(key: key);

  _SearchPlacesPageState createState() => _SearchPlacesPageState();
}

class _SearchPlacesPageState extends State<SearchPlacesPage> {
  TextEditingController queryController = TextEditingController();
  FocusNode queryFocus = FocusNode();
  Timer _debounce;

  GoogleMapsPlaces _placesServices =
      GoogleMapsPlaces(apiKey: "AIzaSyCHOLoxY8hwQzx_dyvDkihq9SpuQeiCGJs");

  List<Prediction> _results = [];

  Future<List<Prediction>> _search(text) async {
    PlacesAutocompleteResponse result =
        await _placesServices.autocomplete(text, language: "pt-br");

    return result.predictions;
  }

  void _handleSearch(String text) {
    _search(text).then((places) {
      setState(() {
        _results = places;
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
            if(text.length < 3) return;
            
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
            hintText: "Pesquise por rua, bairro, cidade...",
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
          return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
              title: Text(_results.elementAt(index)?.description),
              onTap: () {
                Navigator.pop(context, _results.elementAt(index));
              });
        }
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text("Powered by Google")],
          ),
        ),
      ),
    );
  }
}
