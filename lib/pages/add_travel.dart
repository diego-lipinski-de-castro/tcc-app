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

  Future _getDateTime() async {
    try {
      DateTime date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 1, 1),
        lastDate: DateTime(2050, 1, 1)
      );

      TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
                  padding: EdgeInsets.only(top: 10.0),
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
                          suffixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
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
                          suffixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                GestureDetector(
                  onTap: () {
                    _getDateTime()
                      .then((datetime) {
                        print(datetime);
                        _startDate = datetime['date'];
                        _startTime = datetime['time'];
                      })
                      .then((_) {
                        var startMonthText = _startDate.month > 9 ? _startDate.month : "0${_startDate.month}";
                        var startMinuteText = _startTime.minute > 9 ? _startTime.minute : "0${_startTime.minute}";

                        var startDateText = "${_startDate.day}/$startMonthText";
                        var startTimeText = "${_startTime.hour}:$startMinuteText";

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
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                GestureDetector(
                  onTap: () {
                    _getDateTime()
                      .then((datetime) {
                        print(datetime);
                        _backDate = datetime['date'];
                        _backTime = datetime['time'];
                      })
                      .then((_) {
                        var backMonthText = _backDate.month > 9 ? _backDate.month : "0${_backDate.month}";
                        var backMinuteText = _backTime.minute > 9 ? _backTime.minute : "0${_backTime.minute}";

                        var backDateText = "${_backDate.day}/$backMonthText";
                        var backTimeText = "${_backTime.hour}:$backMinuteText";
                        
                        _backDateTimeField.text = '$backDateText $backTimeText';
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
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hasFloatingPlaceholder: false,
                    labelText: "Número total de vagas",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hasFloatingPlaceholder: false,
                    labelText: "Preço da excursão",
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
