import 'package:collection/collection.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/kamtibmas_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

class TodoCalendarPage extends StatefulWidget {
  @override
  _TodoCalendarPageState createState() => _TodoCalendarPageState();
}

class _TodoCalendarPageState extends State<TodoCalendarPage>
    with SingleTickerProviderStateMixin {
  CalendarController _calendarController;
  API _api = API();

  final format = DateFormat("yyyy-MM-dd HH:mm");

  Map<DateTime, List> _events;

  List _selectedEvents;

  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  @override
  void initState() {
    _api.getKamtibmasData(token: _loginModel.token).then((response) {
      if (response.statusCode == 200) {
        KamtibmasModels kamtibmass = KamtibmasModels.fromJson(response.body);

        Map<DateTime, List> newMap =
            groupBy(kamtibmass.list, (f) => f.timestamp).map(
          (k, v) => MapEntry(
            DateTime.fromMillisecondsSinceEpoch(k * 1000),
            v.map(
              (item) {
                var judul = item.judul;
                return judul;
              },
            ).toList(),
          ),
        );

        setState(() {
          _events = newMap;
        });
      }
    });
    initializeDateFormatting();
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Kalender Kamtibmas',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          TableCalendar(
            calendarController: _calendarController,
            locale: 'id_ID',
            events: _events,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            startingDayOfWeek: StartingDayOfWeek.monday,
            builders: CalendarBuilders(
              selectedDayBuilder: (context, date, events) {
                return Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  margin: EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              },
              todayDayBuilder: (context, date, events) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  margin: EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
            onDaySelected: _onDaySelected,
          ),
          Expanded(
            child: _selectedEvents != null
                ? ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemCount: _selectedEvents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${_selectedEvents[index]}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text('Testing deskripsi kalender'),
                          ],
                        ),
                      );
                    },
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}
