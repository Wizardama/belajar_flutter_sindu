import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/rencana_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class TodoDetailPage extends StatefulWidget {
  final Function refresh;
  final String uid;

  TodoDetailPage({@required this.refresh, @required this.uid});

  @override
  _TodoDetailPageState createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();

  Future<http.Response> _futureRG;

  void _refreshData() {
    setState(() {
      _futureRG = _api.getRGDetail(token: _loginModel.token, uid: widget.uid);
    });
  }

  bool _connectionProgres = false;

  void _setRGFinish() {
    setState(() {
      _connectionProgres = true;
    });
    _api
        .getRGFinish(token: _loginModel.token, uid: widget.uid)
        .then((response) {
      if (response.statusCode == 200) {
        _refreshData();

        setState(() {
          _connectionProgres = false;
        });

        widget.refresh();
        Navigator.pop(context);
      } else {
        setState(() {
          _connectionProgres = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _connectionProgres = false;
      });
    });
  }

  void _setRGDelete() {
    setState(() {
      _connectionProgres = true;
    });
    _api
        .getRGDelete(token: _loginModel.token, uid: widget.uid)
        .then((response) {
      if (response.statusCode == 200) {
        _refreshData();

        setState(() {
          _connectionProgres = false;
        });

        widget.refresh();
        Navigator.pop(context);
      } else {
        setState(() {
          _connectionProgres = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _connectionProgres = false;
      });
    });
  }

  void _showDialog({
    @required String message,
    @required bool complete,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          title: Text(
            '$message',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Tidak'),
            ),
            FlatButton(
              onPressed: () {
                if (complete) {
                  _setRGFinish();
                  Navigator.pop(context, true);
                } else {
                  // delete
                  _setRGDelete();
                  Navigator.pop(context, true);
                }
              },
              child: Text('Ya, benar'),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _futureRG = _api.getRGDetail(token: _loginModel.token, uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Detail Rencana Giat',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDialog(
                message: 'Hapus rencana giat ini?',
                complete: false,
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        Container(
          child: FutureBuilder(
            future: _futureRG,
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
                      RencanaDetailModel rencanaDetail =
                          RencanaDetailModel.fromJson(snapshot.data.body);

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Card(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${rencanaDetail.judul}',
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Divider(),
                                SizedBox(height: 8.0),
                                Text(
                                  'Tanggal:',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${rencanaDetail.tglRG}',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'Fakta-fakta:',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${rencanaDetail.fakta}',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'Keterangan:',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${rencanaDetail.keterangan}',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'Catatan:',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${rencanaDetail.catatan}',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Divider(),
                                SizedBox(height: 8.0),
                                FlatButton(
                                  color: Colors.green,
                                  onPressed: () {
                                    _showDialog(
                                      message: 'Konfirmasi telah selesai?',
                                      complete: true,
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 20.0,
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        SizedBox(width: 12.0),
                                        Text(
                                          'Konfirmasi Selesai',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Container();
                  }
              }

              return Container();
            },
          ),
        ),
      ],
    );
  }
}
