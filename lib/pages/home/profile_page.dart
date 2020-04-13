import 'package:cached_network_image/cached_network_image.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  LoginModel _loginModel;

  void _jumpToPage({Widget page}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _resetSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.clear();
    } catch (e) {
      print(e.toString());
    }
  }

  Future _keluarPressed() async {
    _resetSP();

    Navigator.pop(context);
    _jumpToPage(page: LoginPage());
  }

  @override
  void initState() {
    _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Profil',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buttonLogout() {
    return FlatButton(
      color: primaryColor,
      onPressed: () {
        _keluarPressed();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        alignment: Alignment.center,
        child: Text(
          'Keluar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                ClipRRect(
                  child: Container(
                    color: primaryColor,
                    height: 104.0,
                    width: 104.0,
                    child: _loginModel.foto != null
                        ? CachedNetworkImage(imageUrl: _loginModel.foto)
                        : Container(),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                SizedBox(height: 16.0),
                Text(
                  '${_loginModel.nama}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${_loginModel.wilayah}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.0),
          Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${_loginModel.username}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${_loginModel.email}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Nomor telepon',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '+62${_loginModel.noTelepon}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Pangkat',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${_loginModel.pangkat}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          // OutlineButton(
          //   onPressed: () {
          //     // _toChangePasswordPage();
          //   },
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(32.0)),
          //   ),
          //   child: Container(
          //     padding: EdgeInsets.symmetric(
          //       horizontal: 16.0,
          //       vertical: 16.0,
          //     ),
          //     alignment: Alignment.center,
          //     child: Text(
          //       'Ganti password',
          //       style: TextStyle(
          //         color: primaryColor,
          //         fontSize: 16.0,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(height: 16.0),
          _buttonLogout(),
        ],
      ),
    );
  }
}
