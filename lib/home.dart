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
import 'models/MapData.dart';
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
  LatLng _initialPosition = LatLng(-13.7043336, -69.6663944);
  bool _hasPermission = false;
  Travel _selected;
  String _distance;
  String _duration;

  Set<Marker> markers = <Marker>{};
  Set<Polyline> polylines = <Polyline>{};

  Directions.GoogleMapsDirections _directions = Directions.GoogleMapsDirections(
      apiKey: "AIzaSyCHOLoxY8hwQzx_dyvDkihq9SpuQeiCGJs");

  @override
  void initState() {
    super.initState();

    // _init();
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
      _initialPosition = LatLng(location.latitude, location.longitude);
    }

    _mapsController.animateCamera(CameraUpdate.newLatLng(_initialPosition));

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
        flat: true,
        markerId: MarkerId("marker_start"),
        infoWindow:
            InfoWindow(title: _selected.start, snippet: "Ponto de saída"),
        position: LatLng(startLat, startLng)));

    markers.add(Marker(
        markerId: MarkerId("marker_end"),
        infoWindow:
            InfoWindow(title: _selected.destiny, snippet: "Ponto de destino"),
        position: LatLng(endLat, endLng)));

    setState(() {});

    _mapsController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(southwestLat, southwestLng),
            northeast: LatLng(northeastLat, northeastLng)),
        100));
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

        // Timer(Duration(seconds: 1), () {
        //   _mapDataService.add(
        //       _selected.id,
        //       MapData(
        //         travelId: _selected.id,
        //         distance: result.routes.first.legs.first.distance.text,
        //         duration: result.routes.first.legs.first.duration.text,
        //         points: result.routes.first.overviewPolyline.points,
        //         startLat: result.routes.first.legs.first.startLocation.lat,
        //         startLng: result.routes.first.legs.first.startLocation.lng,
        //         endLat: result.routes.first.legs.first.endLocation.lat,
        //         endLng: result.routes.first.legs.first.endLocation.lng,
        //         southwestLat: result.routes.first.bounds.southwest.lat,
        //         southwestLng: result.routes.first.bounds.southwest.lng,
        //         northeastLat: result.routes.first.bounds.northeast.lat,
        //         northeastLng: result.routes.first.bounds.northeast.lng,
        //       ));
        //   _travelService.update(_selected.id);
        // });
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
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível executar ação :(')));
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
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                GoogleMap(
                    onMapCreated: (controller) {
                      _init(controller);
                    },
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 8,
                    ),
                    myLocationEnabled: _hasPermission,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    markers: markers,
                    polylines: polylines),
                if (_selected != null) ...[
                  SafeArea(
                    child: Container(
                      margin: EdgeInsets.all(15.0),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Center(
                        child: Text(
                          _selected.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: 0.5),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 10.0,
                                spreadRadius: 0)
                          ]),
                    ),
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height / 4,
                      child: Container(
                        width: 120,
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Saída",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5.0),
                              ),
                              Text(
                                _selected.startDateTime,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  height: 2.0,
                                  width: 18.0,
                                  color: Color(0xff00c6ff)),
                              Text(
                                "Valor",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5.0),
                              ),
                              Text(
                                "R\$" + _selected.price,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  height: 2.0,
                                  width: 18.0,
                                  color: Color(0xff00c6ff)),
                              Text(
                                "Vagas",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5.0),
                              ),
                              Text(
                                _selected.vagas,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  height: 2.0,
                                  width: 18.0,
                                  color: Color(0xff00c6ff)),
                              Text(
                                "Distância",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5.0),
                              ),
                              Text(
                                _distance ?? "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  height: 2.0,
                                  width: 18.0,
                                  color: Color(0xff00c6ff)),
                              Text(
                                "Tempo",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5.0),
                              ),
                              Text(
                                _duration ?? "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 0),
                                  blurRadius: 10.0,
                                  spreadRadius: 0)
                            ]),
                      ))
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
