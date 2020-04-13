import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/pages/home/profile_page.dart';
import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/pages/home/digital_mapping_page.dart';
import 'package:digimap_pandonga/pages/home/chat_page.dart';
import 'package:digimap_pandonga/pages/home/about_page.dart';
import 'package:digimap_pandonga/pages/home/help_page.dart';
import 'package:digimap_pandonga/pages/home/todo_page.dart';

class LauncherPage extends StatefulWidget {
  @override
  _LauncherPageState createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);

  API _api = API();

  void _jumpToPage({Widget page}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<bool> _dialogBackPressed() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          title: Text(
            'Apa anda yakin akan menutup aplikasi?',
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
              onPressed: () => Navigator.pop(context, true),
              child: Text('Ya, tentu'),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Prepare cache
    _api.getFilterData(token: _loginModel.token).then((response) {
      if (response.statusCode == 200) {
        SingletonModel.shared.filter = response.body;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            backgroundColor: primaryColor,
          ),
          preferredSize: Size(0.0, 0.0),
        ),
        body: _buildBody(),
      ),
      onWillPop: _dialogBackPressed,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            height: 264.0,
            width: double.infinity,
            color: primaryColor,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  top: 0.0,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Image.asset(
                      'assets/images/bg_pattern.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60.0,
                  right: -32.0,
                  child: Container(
                    width: 240.0,
                    height: 240.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              _greeting(),
              _menu(),
            ],
          )
        ],
      ),
    );
  }

  Widget _greeting() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.0,
        40.0,
        20.0,
        16.0,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  new IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  // Positioned(
                  //   right: 8,
                  //   top: 8,
                  //   child: new Container(
                  //     padding: EdgeInsets.all(2),
                  //     decoration: new BoxDecoration(
                  //       color: Colors.blue,
                  //       borderRadius: BorderRadius.circular(6),
                  //     ),
                  //     constraints: BoxConstraints(
                  //       minWidth: 14,
                  //       minHeight: 14,
                  //     ),
                  //     child: Text(
                  //       '16',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 8,
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Stack(
                children: <Widget>[
                  new IconButton(
                    icon: Icon(
                      Icons.message,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _jumpToPage(page: ChatPage());
                    },
                  ),
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection('message_data')
                        .where('read_map.${_loginModel.uid}', isEqualTo: false)
                        .limit(10)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length > 0) {
                          int unread = 0;

                          // get last message
                          snapshot.data.documents.forEach((f) {
                            Map readMap = f['read_map'];

                            if (readMap['${_loginModel.uid}'] == false) {
                              unread++;
                            }
                          });

                          if (unread > 0) {
                            return Positioned(
                              right: 8,
                              top: 8,
                              child: new Container(
                                padding: EdgeInsets.all(2),
                                decoration: new BoxDecoration(
                                  color: Colors.red[900],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  unread > 9 ? '9+' : '$unread',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }
                      }
                      return Container();
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onPressed: () {
                  _jumpToPage(page: ProfilPage());
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 24.0),
                    Text(
                      'Halo',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_loginModel.nama}, ${_loginModel.wilayah}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _menu() {
    final gridCount = MediaQuery.of(context).size.width ~/ 160.0;
    final deviceWith = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
      child: GridView(
        shrinkWrap: true,
        primary: false,
        physics: ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.96,
        ),
        children: <Widget>[
          _itemMenu(
            title: 'Sebaran Covid-19',
            icon: Icon(
              Icons.extension,
              size: deviceWith <= 320 ? 32 : 48,
              color: Colors.red,
            ),
            onTap: () {},
          ),
          _itemMenu(
            title: 'Potensi Konflik & Kejadian Menonjol',
            icon: Icon(
              Icons.location_on,
              size: deviceWith <= 320 ? 32 : 48,
              color: Colors.red,
            ),
            onTap: () {
              _jumpToPage(page: DigitalMappingPage());
            },
          ),
          _itemMenu(
            title: 'Daftar Rencana Giat',
            icon: Icon(
              Icons.format_list_numbered,
              size: deviceWith <= 320 ? 32 : 48,
              color: Colors.red,
            ),
            onTap: () {
              _jumpToPage(page: TodoPage());
            },
          ),
          _itemMenu(
            title: 'Panduan Aplikasi',
            icon: Icon(
              Icons.help,
              size: deviceWith <= 320 ? 32 : 48,
              color: Colors.red,
            ),
            onTap: () {
              _jumpToPage(page: HelpPage());
            },
          ),
          _itemMenu(
            title: 'Tentang Aplikasi',
            icon: Icon(
              Icons.info,
              size: deviceWith <= 320 ? 32 : 48,
              color: Colors.red,
            ),
            onTap: () {
              _jumpToPage(page: AboutPage());
            },
          ),
        ],
      ),
    );
  }

  Widget _itemMenu({
    @required String title,
    @required Icon icon,
    Function onTap,
  }) {
    return GestureDetector(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              icon,
              SizedBox(height: 8.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
