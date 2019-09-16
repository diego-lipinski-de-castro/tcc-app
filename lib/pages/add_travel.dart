import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import '../widgets/search_places.dart';

class AddTravelPage extends StatefulWidget {
  @override
  _AddTravelPageState createState() => _AddTravelPageState();
}

class _AddTravelPageState extends State<AddTravelPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _startingPlaceField = TextEditingController();
  TextEditingController _destinationPlaceField = TextEditingController();

  TextEditingController _startDateTimeField = TextEditingController();
  TextEditingController _backDateTimeField = TextEditingController();

  Prediction _start;
  Prediction _destination;

  DateTime _startDate;
  TimeOfDay _startTime;

  DateTime _backDate;
  TimeOfDay _backTime;

  Future _getDateTime(DateTime initialDate, TimeOfDay initialTime) async {
    try {
      DateTime date = await showDatePicker(
        context: context,
        initialDate: initialDate == null ? DateTime.now() : initialDate,
        firstDate: DateTime(2015, 1, 1),
        lastDate: DateTime(2050, 1, 1)
      );

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

      return {
        'date': date,
        'time': time
      };

    } catch (error) {
      print(error);
      return null;
    }
  }

  _createTravel() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar uma excursão'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
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
                              content: Text("O título será usado para as pessoas pesquisarem e encontraram sua excursão, pode usar o nome do evento por exemplo."),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Entendi"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          }
                        );
                      },
                    )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                GestureDetector(
                  onTap: () async {
                    _start = await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SearchPlacesPage()));
                    _startingPlaceField.text = _start?.description;
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _startingPlaceField,
                        readOnly: true,
                        decoration: InputDecoration(
                          hasFloatingPlaceholder: false,
                          labelText: "Local de saída",
                          suffixIcon: Icon(Icons.location_on)
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
                            builder: (context) => SearchPlacesPage()));
                    _destinationPlaceField.text = _destination?.description;
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _destinationPlaceField,
                        readOnly: true,
                        decoration: InputDecoration(
                          hasFloatingPlaceholder: false,
                          labelText: "Destino (localização do evento)",
                          suffixIcon: Icon(Icons.location_on)
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                GestureDetector(
                  onTap: () {
                    _getDateTime(_startDate, _startTime)
                      .then((datetime) {
                        _startDate = datetime['date'];
                        _startTime = datetime['time'];
                      })
                      .then((_) {
                        var startDayText = _startDate.day > 9 ? _startDate.day : "0${_startDate.day}";
                        var startMonthText = _startDate.month > 9 ? _startDate.month : "0${_startDate.month}";

                        var startHourText = _startTime.hour > 9 ? _startTime.hour : "0${_startTime.hour}";
                        var startMinuteText = _startTime.minute > 9 ? _startTime.minute : "0${_startTime.minute}";

                        var startDateText = '$startDayText/$startMonthText';
                        var startTimeText = '$startHourText:$startMinuteText';

                        _startDateTimeField.text = '$startDateText $startTimeText';
                      });
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _startDateTimeField,
                        readOnly: true,
                        decoration: InputDecoration(
                          hasFloatingPlaceholder: false,
                          labelText: "Data e horário de saida",
                          suffixIcon: Icon(Icons.calendar_today)
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                GestureDetector(
                  onTap: () {
                    _getDateTime(_backDate, _backTime)
                      .then((datetime) {
                        _backDate = datetime['date'];
                        _backTime = datetime['time'];
                      })
                      .then((_) {
                        var backDayText = _backDate.day > 9 ? _backDate.day : "0${_backDate.day}";
                        var backMonthText = _backDate.month > 9 ? _backDate.month : "0${_backDate.month}";

                        var backHourText = _backTime.hour > 9 ? _backTime.hour : "0${_backTime.hour}";
                        var backMinuteText = _backTime.minute > 9 ? _backTime.minute : "0${_backTime.minute}";

                        var backDateText = '$backDayText/$backMonthText';
                        var backTimeText = '$backHourText:$backMinuteText';

                        _backDateTimeField.text = '$backDateText $backTimeText';
                      });
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _backDateTimeField,
                        readOnly: true,
                        decoration: InputDecoration(
                          hasFloatingPlaceholder: false,
                          labelText: "Data e horário de saida",
                          suffixIcon: Icon(Icons.calendar_today)
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hasFloatingPlaceholder: false,
                    labelText: "Número total de vagas"
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hasFloatingPlaceholder: false,
                    labelText: "Preço da excursão"
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: _createTravel
      ),
    );
  }
}
