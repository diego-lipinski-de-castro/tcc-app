import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc/services/auth.dart';
import 'package:tcc/services/permission.dart';
import 'package:tcc/pages/add_travel.dart';
import 'package:geolocator/geolocator.dart';
import 'widgets/search_travels.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  AuthService _authService = AuthService();
  GoogleMapController _mapsController;
  LatLng _initialPosition;
  bool _hasPermission = false;
  TextEditingController _searchInput = TextEditingController();
  FocusNode _searchInputFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _searchInputFocus.addListener(_searchInputFocusListener);

    _init();
  }

  @override
  void dispose() {
    _searchInputFocus.removeListener(_searchInputFocusListener);
    super.dispose();
  }

  _searchInputFocusListener() {
    if (_searchInputFocus.hasFocus) {}
  }

  _init() async {
    bool hasPermission = await Permission.checkAndRequestLocation();

    if (hasPermission) {
      Position location = await _getCurrentLocation();

      setState(() {
        _initialPosition = LatLng(location.latitude, location.longitude);
        _hasPermission = hasPermission;
      });
      // _animateToUser(location.latitude, location.altitude);
    }
  }

  Future<Position> _getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  // void _animateToUser(lat, lng) {
  //  _mapsController.animateCamera(CameraUpdate.newCameraPosition(
  //    CameraPosition(
  //      target: LatLng(lat, lng),
  //      zoom: 18
  //    )
  //  ));
  // }

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
                _initialPosition == null
                    ? Container(
                        child: Center(
                          child: _hasPermission
                              ? CircularProgressIndicator()
                              : Text(
                                  "Sem permissão para acessar sua localização atual."),
                        ),
                      )
                    : GoogleMap(
                        onMapCreated: (controller) {
                          _mapsController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 15,
                        ),
                        myLocationEnabled: _hasPermission,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                      ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  if (loggedIn) ...[
                    UserAccountsDrawerHeader(
                      accountName: Text(user.displayName),
                      accountEmail: Text(user.email),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                    ),
                    ListTile(
                      title: Text("Logout"),
                      onTap: () {
                        Navigator.of(context).pop();
                        _authService.googleSignOut();
                      },
                    )
                  ]
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton.extended(
              elevation: 4.0,
              label: const Text('Pesquisar'),
              icon: const Icon(Icons.search),
              onPressed: () async {
                var test = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchTravels()));

                print(test);
              },
            ),
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
                          onPressed: () {
                            _authService.googleSignIn();
                          },
                        ),
                      ],
                      if (loggedIn) ...[
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            _scaffoldKey.currentState.openDrawer();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddTravelPage()));
                          },
                        ),
                      ]
                    ],
                  ),
                  // Padding(
                  //   padding:
                  //       EdgeInsets.symmetric(vertical: 25.0, horizontal: 40.0),
                  //   child: TextField(
                  //     focusNode: _searchInputFocus,
                  //     controller: _searchInput,
                  //     decoration: InputDecoration(
                  //       hasFloatingPlaceholder: false,
                  //       labelText: "Para qual evento deseja ir?",
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        });
  }
}
