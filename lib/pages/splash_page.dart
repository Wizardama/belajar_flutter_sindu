import 'dart:async';

import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/pages/auth/login_page.dart';
import 'package:digimap_pandonga/pages/launcher_page.dart';

// Ext
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  SharedPreferences _pref;

  Timer _changeToPage({Widget page}) {
    return Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  void _splashStarted() async {
    _pref = await SharedPreferences.getInstance();

    String loginData = _pref.getString(loginIdentifierSP);

    if (loginData != null) {
      SingletonModel.shared.login = loginData;
      _changeToPage(page: LauncherPage());
    } else {
      _changeToPage(page: LoginPage());
    }
  }

  @override
  void initState() {
    super.initState();
    _splashStarted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: primaryColor,
        ),
        preferredSize: Size(0.0, 0.0),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: [
            Color(0xFFFF3F34),
            Color(0xFFFF5E57),
          ],
        ),
      ),
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
          Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo_sindu.png',
                    height: 156.0,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Digital Mapping',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -60.0,
            right: -60.0,
            child: Container(
              width: 280.0,
              height: 280.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: 32.0,
            left: 0.0,
            right: 0.0,
            child: Text(
              'Direktorat Intelijen Keamanan\nPolda Jawa Tengah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
