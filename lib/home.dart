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

  AuthService _authService = AuthService.singleton();
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

  Travel _travel;
  String _distance;
  String _duration;

  bool _openDetail = false;

  @override
  void initState() {
    super.initState();

    Geolocator().forceAndroidLocationManager = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _init(controller) async {
    _mapsController = controller;

    bool hasPermission = await Permission.checkAndRequestLocation();
    _hasPermission = hasPermission;

    Position location;

    if (hasPermission) {
      location = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } else {
      location = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    }

    _initialPosition = CameraPosition(
        target: LatLng(location.latitude, location.longitude), zoom: 10);

    _defaultPosition = _initialPosition;

    _mapsController.animateCamera(CameraUpdate.newLatLngZoom(
        _initialPosition.target, _initialPosition.zoom));

    setState(() {});
  }

  _updateUi(
      {Travel travel,
      distance,
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
        // infoWindow: InfoWindow(title: _travel.start, snippet: "Ponto de saída"),
        position: LatLng(startLat, startLng)));

    markers.add(Marker(
        consumeTapEvents: false,
        markerId: MarkerId("marker_end"),
        // infoWindow: InfoWindow(title: _travel.destiny, snippet: "Ponto de destino"),
        position: LatLng(endLat, endLng)));

    setState(() {
      _travel = travel;
    });

    _mapsController.animateCamera(CameraUpdate.zoomOut());

    _mapsController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(southwestLat, southwestLng),
            northeast: LatLng(northeastLat, northeastLng)),
        100));
  }

  _loadUi(Travel travel) async {
    try {
      if (travel.hasMapsDoc) {
        MapData result = await _mapDataService.get(travel.id);

        _updateUi(
            travel: travel,
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
            .directionsWithAddress(travel.start, travel.destiny,
                language: "pt-br");

        _updateUi(
          travel: travel,
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
              travel.id,
              MapData(
                travelId: travel.id,
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

          _travelService.update(travel.id);
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
        stream: AuthService.userStream,
        builder: (context, snapshot) {
          FirebaseUser user = AuthService.user;
          bool loggedIn = user != null;

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
                  // zoomGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
                if (_travel != null) ...[
                  SafeArea(
                    child: Container(
                        margin: EdgeInsets.all(15.0),
                        padding: EdgeInsets.all(15.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Text(
                          _travel.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: 0.5),
                        )),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 40.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              // duration: Duration(milliseconds: 300),
                              height: _openDetail
                                  ? MediaQuery.of(context).size.height / 1.6
                                  : null,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                15,
                                            padding: EdgeInsets.all(15.0),
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  "Local de saída",
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  _travel.start,
                                                  overflow: _openDetail
                                                      ? TextOverflow.visible
                                                      : TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                15,
                                            padding: EdgeInsets.all(15.0),
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  "Local de chegada",
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  _travel.destiny,
                                                  overflow: _openDetail
                                                      ? TextOverflow.visible
                                                      : TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_openDetail) ...[
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
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
                                                    _travel.startDateTime,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
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
                                                    _travel.backDateTime,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
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
                                                    _travel.vagas,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
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
                                                    "R\$" + _travel.price,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(15.0),
                                        child: Text(_travel.description,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 10,
                                            textAlign: TextAlign.center),
                                      )
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                child: FlatButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.symmetric(vertical: 15.0),
                                  onPressed: () {
                                    setState(() {
                                      _openDetail = !_openDetail;
                                    });
                                  },
                                  child: Text(
                                    "Mais informações",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                )),
                          ],
                        )),
                  ),
                ],
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _travel == null
                ? FloatingActionButton.extended(
                    heroTag: null,
                    elevation: 4.0,
                    label: const Text('Pesquisar'),
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      Travel travel = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SearchTravels()));

                      if (travel != null) {
                        _loadUi(travel);
                      }
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
                            _openWhats(_travel.phone, _travel.title);
                          },
                        ),
                        FloatingActionButton.extended(
                          heroTag: null,
                          elevation: 4.0,
                          label: const Text('Fechar'),
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _travel = null;
                              _distance = null;
                              _duration = null;
                              _openDetail = false;
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
                      if (!loggedIn) ...[
                        IconButton(
                          icon: Icon(Icons.account_circle),
                          onPressed: () async {
                            await _authService.googleSignIn();
                          },
                        ),
                      ],
                      if (loggedIn) ...[
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.photoUrl),
                              ),
                            ),
                          ),
                        ),
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
