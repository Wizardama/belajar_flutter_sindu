import 'package:digimap_pandonga/pages/home/todo_calendar_page.dart';
import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/models/rencana_model.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/pages/home/todo_detail_page.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';

// Ext
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();

  Future<http.Response> _futureRGs;
  Future<http.Response> _futureRGMs;

  void _jumpToPage({Widget page}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _refreshData() {
    setState(() {
      _futureRGs = _api.getRGData(token: _loginModel.token, today: true);
      _futureRGMs = _api.getRGData(token: _loginModel.token, month: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _futureRGs = _api.getRGData(token: _loginModel.token, today: true);
    _futureRGMs = _api.getRGData(token: _loginModel.token, month: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            'Rencana Giat',
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          bottom: TabBar(tabs: [
            Tab(
              text: 'Hari Ini',
            ),
            Tab(
              text: 'Bulan Ini',
            ),
          ]),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () {
                _jumpToPage(page: TodoCalendarPage());
              },
            )
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(children: [
      FutureBuilder(
        future: _futureRGs,
        builder: (context, AsyncSnapshot<http.Response> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitCubeGrid(
                      color: primaryColor,
                      size: 32.0,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Sedang memuat data.',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                if (snapshot.data.statusCode == 200) {
                  WilayahRGModels wilayahs =
                      WilayahRGModels.fromJson(snapshot.data.body);

                  return _listRG(wilayahs);
                }
              } else if (snapshot.hasError) {
                return Container();
              }
          }

          return Container();
        },
      ),
      FutureBuilder(
        future: _futureRGMs,
        builder: (context, AsyncSnapshot<http.Response> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitCubeGrid(
                      color: primaryColor,
                      size: 32.0,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Sedang memuat data.',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                if (snapshot.data.statusCode == 200) {
                  WilayahRGModels wilayahs =
                      WilayahRGModels.fromJson(snapshot.data.body);

                  return _listRG(wilayahs);
                }
              } else if (snapshot.hasError) {
                return Container();
              }
          }

          return Container();
        },
      ),
    ]);
  }

  Widget _listRG(WilayahRGModels wilayahs) {
    final theme = Theme.of(context).copyWith(
      accentColor: Colors.black87,
      dividerColor: Colors.transparent,
    );

    return Container(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(
                color: Colors.grey[400],
                width: 0.6,
              ),
            ),
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: wilayahs.list.length,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(height: 1.0),
              itemBuilder: (BuildContext context, int index) {
                return Theme(
                  data: theme,
                  child: ExpansionTile(
                    title: Text(
                      '${wilayahs.list[index].namaWilayah}',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text('Total giat: ${wilayahs.list[index].total}'),
                    children: [
                      // _stepBuilder(_stepDigitalMapping),
                      _itemRGBuilder(wilayahs.list[index].rencana)
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRGBuilder(List<RencanaModel> todos) {
    int a = 0;
    return Container(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: todos.map((f) {
          a++;

          return GestureDetector(
            child: Container(
              color: Colors.red.withOpacity(0.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('$a.'),
                    padding: EdgeInsets.only(right: 16.0),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${f.judul}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Container(
                            width: 60.0,
                            height: 1.4,
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  )
                ],
              ),
            ),
            onTap: () {
              _jumpToPage(
                page: TodoDetailPage(refresh: _refreshData, uid: f.uid),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
