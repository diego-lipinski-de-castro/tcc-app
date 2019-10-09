import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc/services/auth.dart';
import 'package:tcc/services/permission.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcc/services/map_data.dart';
import 'package:tcc/services/travel.dart';
import 'widgets/search_travels.dart';
import 'models/Travel.dart';
import 'package:google_maps_webservice/directions.dart' as Directions;
import 'utils/maps.dart';
import 'pages/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/map_data.dart';
import 'pages/list_travels.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  AuthService _authService = AuthService();
  TravelService _travelService = TravelService();
  MapDataService _mapDataService = MapDataService();

  GoogleMapController _mapsController;

  CameraPosition _defaultPosition;
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(-14.235004, -51.92528), zoom: 4);

  Directions.GoogleMapsDirections _directions = Directions.GoogleMapsDirections(
      apiKey: "AIzaSyCHOLoxY8hwQzx_dyvDkihq9SpuQeiCGJs");

  Set<Marker> markers = <Marker>{};
  Set<Polyline> polylines = <Polyline>{};

  bool _hasPermission = false;

  Travel _selected;
  String _distance;
  String _duration;

  bool openDetail = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _init(controller) async {
    _mapsController = controller;

    bool hasPermission = await Permission.checkAndRequestLocation();
    _hasPermission = hasPermission;

    if (hasPermission) {
      Position location = await _getCurrentLocation();
      _initialPosition = CameraPosition(
          target: LatLng(location.latitude, location.longitude), zoom: 15);
    }

    _defaultPosition = _initialPosition;

    _mapsController.animateCamera(CameraUpdate.newLatLngZoom(
        _initialPosition.target, _initialPosition.zoom));

    setState(() {});
  }

  Future<Position> _getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  _updateUi(
      {distance,
      duration,
      points,
      startLat,
      startLng,
      endLat,
      endLng,
      southwestLat,
      southwestLng,
      northeastLat,
      northeastLng}) async {
    _distance = distance;
    _duration = duration;

    polylines.add(Polyline(
        polylineId: PolylineId("polyline"),
        consumeTapEvents: false,
        color: Colors.orange,
        width: 3,
        points: MapsHelper.convertToLatLng(MapsHelper.decodePoly(points))));

    markers.add(Marker(
        consumeTapEvents: false,
        markerId: MarkerId("marker_start"),
        // infoWindow: InfoWindow(title: _selected.start, snippet: "Ponto de saída"),
        position: LatLng(startLat, startLng)));

    markers.add(Marker(
        consumeTapEvents: false,
        markerId: MarkerId("marker_end"),
        // infoWindow: InfoWindow(title: _selected.destiny, snippet: "Ponto de destino"),
        position: LatLng(endLat, endLng)));

    setState(() {});

    _mapsController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(southwestLat, southwestLng),
            northeast: LatLng(northeastLat, northeastLng)),
        50));
  }

  _loadUi() async {
    try {
      if (_selected.hasMapsDoc) {
        MapData result = await _mapDataService.get(_selected.id);

        _updateUi(
            distance: result.distance,
            duration: result.duration,
            points: result.points,
            startLat: result.startLat,
            startLng: result.startLng,
            endLat: result.endLat,
            endLng: result.endLng,
            southwestLat: result.southwestLat,
            southwestLng: result.southwestLng,
            northeastLat: result.northeastLat,
            northeastLng: result.northeastLng);
      } else {
        Directions.DirectionsResponse result = await _directions
            .directionsWithAddress(_selected.start, _selected.destiny,
                language: "pt-br");

        _updateUi(
          distance: result.routes.first.legs.first.distance.text,
          duration: result.routes.first.legs.first.duration.text,
          points: result.routes.first.overviewPolyline.points,
          startLat: result.routes.first.legs.first.startLocation.lat,
          startLng: result.routes.first.legs.first.startLocation.lng,
          endLat: result.routes.first.legs.first.endLocation.lat,
          endLng: result.routes.first.legs.first.endLocation.lng,
          southwestLat: result.routes.first.bounds.southwest.lat,
          southwestLng: result.routes.first.bounds.southwest.lng,
          northeastLat: result.routes.first.bounds.northeast.lat,
          northeastLng: result.routes.first.bounds.northeast.lng,
        );

        Timer(Duration(seconds: 1), () {
          _mapDataService.add(
              _selected.id,
              MapData(
                travelId: _selected.id,
                distance: result.routes.first.legs.first.distance.text,
                duration: result.routes.first.legs.first.duration.text,
                points: result.routes.first.overviewPolyline.points,
                startLat: result.routes.first.legs.first.startLocation.lat,
                startLng: result.routes.first.legs.first.startLocation.lng,
                endLat: result.routes.first.legs.first.endLocation.lat,
                endLng: result.routes.first.legs.first.endLocation.lng,
                southwestLat: result.routes.first.bounds.southwest.lat,
                southwestLng: result.routes.first.bounds.southwest.lng,
                northeastLat: result.routes.first.bounds.northeast.lat,
                northeastLng: result.routes.first.bounds.northeast.lng,
              ));

          _travelService.update(_selected.id);
        });
      }
    } catch (error) {
      print("error");
      print(error);
    }
  }

  _openWhats(String phoneNumber, String title) async {
    final text =
        Uri.encodeFull('Olá, ainda possui vagas para a excursão $title?');

    String whatsUrl = 'https://wa.me/$phoneNumber/?text=$text';
    String url = 'tel:$phoneNumber';

    print('url');
    print(url);

    try {
      bool canWhats = await canLaunch(whatsUrl);

      if (canWhats) {
        await launch(whatsUrl);
      } else {
        bool canPhone = await canLaunch(url);

        if (canPhone) {
          await launch(url);
        }
      }
    } catch (error) {
      print(error);
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Não foi possível executar aç������������o :(')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          ConnectionState state = snapshot.connectionState;
          bool loggedIn = _authService.user != null;
          FirebaseUser user = _authService.user;

          if (state == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: (controller) {
                    _init(controller);
                  },
                  initialCameraPosition: _initialPosition,
                  myLocationEnabled: _hasPermission,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  markers: markers,
                  polylines: polylines,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
                if (_selected != null) ...[
                  SafeArea(
                    child: Container(
                      margin: EdgeInsets.all(15.0),
                      padding: EdgeInsets.all(15.0),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          _selected.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: 0.5),
                        ),
                      ]),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 45.0),
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                          15,
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Local de saída",
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        _selected.start,
                                        overflow: openDetail ? TextOverflow.visible : TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                          15,
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Local de chegada",
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        _selected.destiny,
                                        overflow: openDetail ? TextOverflow.visible : TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (openDetail) ...[
                              Container(
                                height: 2,
                                width: 50,
                                color: Colors.deepPurple,
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        15,
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Data de saída",
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          _selected.startDateTime,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        15,
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Data de volta",
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          _selected.backDateTime,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 2,
                                width: 50,
                                color: Colors.deepPurple,
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        15,
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Total de vagas",
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          _selected.vagas,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        15,
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Preço",
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "R\$" + _selected.price,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 2,
                                width: 50,
                                color: Colors.deepPurple,
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                            ],
                            FlatButton(
                              onPressed: () {
                                setState(() {
                                  openDetail = !openDetail;
                                });
                              },
                              child: Text("Mais informações"),
                            )
                          ],
                        )),
                  ),
                ]
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _selected == null
                ? FloatingActionButton.extended(
                    heroTag: null,
                    elevation: 4.0,
                    label: const Text('Pesquisar'),
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      _selected = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SearchTravels()));

                      _loadUi();
                    },
                  )
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 75.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton.extended(
                          heroTag: null,
                          elevation: 4.0,
                          label: const Text('Quero'),
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            _openWhats(_selected.phone, _selected.title);
                          },
                        ),
                        FloatingActionButton.extended(
                          heroTag: null,
                          elevation: 4.0,
                          label: const Text('Fechar'),
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selected = null;
                              _distance = null;
                              _duration = null;
                              markers = {};
                              polylines = {};
                            });

                            _mapsController.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    _defaultPosition.target,
                                    _defaultPosition.zoom));
                          },
                        )
                      ],
                    )),
            bottomNavigationBar: BottomAppBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.account_circle),
                        onPressed: () {
                          if (loggedIn) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProfilePage()));
                          } else {
                            _authService.googleSignIn();
                          }
                        },
                      ),
                      if (loggedIn) ...[
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ListTravelPage()));
                          },
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
