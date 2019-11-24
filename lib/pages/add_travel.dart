import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import '../widgets/search_places.dart';
import '../services/travel.dart';
import '../models/travel.dart';

class AddTravelPage extends StatefulWidget {
  @override
  _AddTravelPageState createState() => _AddTravelPageState();
}

class _AddTravelPageState extends State<AddTravelPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TravelService _travelService = TravelService();

  final _startingPlaceField = TextEditingController();
  final _destinationPlaceField = TextEditingController();

  final _startDateTimeField = TextEditingController();
  final _backDateTimeField = TextEditingController();

  final _titleController = TextEditingController();
  final _vagasField = TextEditingController();
  final _priceField = TextEditingController();

  final _descriptionField = TextEditingController();

  Prediction _start;
  Prediction _destination;

  DateTime _startDate;
  TimeOfDay _startTime;

  DateTime _backDate;
  TimeOfDay _backTime;

  KeyboardVisibilityNotification _keyboard =
      new KeyboardVisibilityNotification();
  int _keyboardListener;
  bool _keyboardVisible;

  @override
  void initState() {
    super.initState();

    _keyboardVisible = _keyboard.isKeyboardVisible;

    _keyboardListener = _keyboard.addNewListener(
      onChange: (bool visible) {
        setState(() {
          _keyboardVisible = visible;
        });
      },
    );
  }

  @override
  void dispose() {
    _keyboard.removeListener(_keyboardListener);

    super.dispose();
  }

  Future _getDateTime(DateTime initialDate, TimeOfDay initialTime) async {
    try {
      DateTime date = await showDatePicker(
          context: context,
          initialDate: initialDate == null ? DateTime.now() : initialDate,
          firstDate: DateTime(2015, 1, 1),
          lastDate: DateTime(2050, 1, 1));

      if (date == null) {
        return null;
      }

      TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: initialTime == null ? TimeOfDay.now() : initialTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        },
      );

      if (date == null) {
        return null;
      }

      return {'date': date, 'time': time};
    } catch (error) {
      print(error);
      return null;
    }
  }

  _createTravel() {
    if (_formKey.currentState.validate()) {
      Travel travel = Travel(
          title: _titleController.text,
          start: _startingPlaceField.text,
          destiny: _destinationPlaceField.text,
          startDateTime: _startDateTimeField.text,
          backDateTime: _backDateTimeField.text,
          vagas: _vagasField.text,
          price: _priceField.text,
          description: _descriptionField.text);

      if (travel.isValid()) {
        _travelService.add(travel);
        Navigator.of(context).pop();
      } else {
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Preencha todos os campos obrigatórios!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Cadastrar uma excursão'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Campo obrigatório';
                    }

                    return null;
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                    hasFloatingPlaceholder: false,
                    labelText: "Título (nome do evento)",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.help),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(
                                    "O título será usado para as pessoas pesquisarem e encontraram sua excursão, pode usar o nome do evento por exemplo."),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Entendi"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                GestureDetector(
                  onTap: () async {
                    _start = await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SearchPlacesPage(), settings: RouteSettings(name: '/search-places-start')));

                    _startingPlaceField.text = _start?.description;
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _startingPlaceField,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Campo obrigatório';
                          }

                          return null;
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          hasFloatingPlaceholder: false,
                          labelText: "Local de saída",
                          suffixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                GestureDetector(
                  onTap: () async {
                    _destination = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => SearchPlacesPage(), settings: RouteSettings(name: '/search-places-destination')));
                    _destinationPlaceField.text = _destination.description;
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _destinationPlaceField,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Campo obrigatório';
                          }

                          return null;
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                            hasFloatingPlaceholder: false,
                            labelText: "Destino (localização do evento)",
                            suffixIcon: Icon(Icons.location_on)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                GestureDetector(
                  onTap: () async {
                    var datetime = await _getDateTime(_startDate, _startTime);

                    if (datetime == null) {
                      return;
                    }

                    _startDate = datetime['date'];
                    _startTime = datetime['time'];

                    var startDayText = _startDate.day > 9
                        ? _startDate.day
                        : "0${_startDate.day}";
                    var startMonthText = _startDate.month > 9
                        ? _startDate.month
                        : "0${_startDate.month}";

                    var startHourText = _startTime.hour > 9
                        ? _startTime.hour
                        : "0${_startTime.hour}";
                    var startMinuteText = _startTime.minute > 9
                        ? _startTime.minute
                        : "0${_startTime.minute}";

                    var startDateText = '$startDayText/$startMonthText';
                    var startTimeText = '$startHourText:$startMinuteText';

                    _startDateTimeField.text = '$startDateText $startTimeText';
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _startDateTimeField,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Campo obrigatório';
                          }

                          return null;
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                            hasFloatingPlaceholder: false,
                            labelText: "Data e horário de saida",
                            suffixIcon: Icon(Icons.calendar_today)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                GestureDetector(
                  onTap: () async {
                    var datetime = await _getDateTime(_backDate, _backTime);

                    if (datetime == null) {
                      return;
                    }

                    _backDate = datetime['date'];
                    _backTime = datetime['time'];

                    var backDayText =
                        _backDate.day > 9 ? _backDate.day : "0${_backDate.day}";
                    var backMonthText = _backDate.month > 9
                        ? _backDate.month
                        : "0${_backDate.month}";

                    var backHourText = _backTime.hour > 9
                        ? _backTime.hour
                        : "0${_backTime.hour}";
                    var backMinuteText = _backTime.minute > 9
                        ? _backTime.minute
                        : "0${_backTime.minute}";

                    var backDateText = '$backDayText/$backMonthText';
                    var backTimeText = '$backHourText:$backMinuteText';

                    _backDateTimeField.text = '$backDateText $backTimeText';
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _backDateTimeField,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Campo obrigatório';
                          }

                          return null;
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                            hasFloatingPlaceholder: false,
                            labelText: "Data e horário de volta",
                            suffixIcon: Icon(Icons.calendar_today)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                TextFormField(
                  controller: _vagasField,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Campo obrigatório';
                    }

                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hasFloatingPlaceholder: false,
                      labelText: "Número total de vagas"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                TextFormField(
                  controller: _priceField,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Campo obrigatório';
                    }

                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hasFloatingPlaceholder: false,
                      labelText: "Preço da excursão"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                TextFormField(
                  controller: _descriptionField,
                  maxLength: 400,
                  minLines: 1,
                  maxLines: 8,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      hasFloatingPlaceholder: false, labelText: "Descrição"),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 75.0),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: !_keyboardVisible,
        child: FloatingActionButton(
            child: Icon(Icons.check), onPressed: _createTravel),
      ),
    );
  }
}
