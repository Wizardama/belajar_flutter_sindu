import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/pages/launcher_page.dart';

// Ext
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  API _api = API();
  SharedPreferences _pref;

  String _errorMessage;
  bool _connectionProgres = false;
  bool _showPassword = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  void _changeToPage({Widget page}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LauncherPage()),
    );
  }

  void _loginPressed() {
    setState(() {
      _connectionProgres = true;
    });

    _api
        .postAuth(username: _username.text, password: _password.text)
        .then((response) async {
      if (response.statusCode == 200) {
        SingletonModel.shared.login = response.body;

        // Save to SP
        _pref = await SharedPreferences.getInstance();
        _pref.setString(loginIdentifierSP, response.body);

        setState(() {
          _connectionProgres = false;
        });

        // Go to launcher
        _changeToPage(page: LauncherPage());
      } else {
        setState(() {
          _connectionProgres = false;
          _errorMessage = 'Periksa username atau password.';
        });
      }
    }).catchError((error) {
      setState(
        () {
          _connectionProgres = false;
          _errorMessage = error.toString();
        },
      );
    });
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
    FocusNode usernameFN = FocusNode();
    FocusNode passwordFN = FocusNode();

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
          Container(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 72.0),
                    Container(
                      child: Image.asset(
                        'assets/images/logo_sindu.png',
                        height: 148.0,
                      ),
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
                    SizedBox(height: 32.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87.withOpacity(0.2),
                            offset: new Offset(4.0, 4.0),
                            blurRadius: 32.0,
                          )
                        ],
                      ),
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _username,
                            textInputAction: TextInputAction.next,
                            focusNode: usernameFN,
                            keyboardType: TextInputType.text,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(passwordFN);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Tolong masukan username anda.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey[100],
                              filled: true,
                              hintText: 'Username',
                              prefixIcon: Icon(
                                Icons.account_circle,
                                color: Colors.grey,
                                size: 32.0,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(32.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _password,
                            textInputAction: TextInputAction.done,
                            focusNode: passwordFN,
                            keyboardType: TextInputType.text,
                            obscureText: !_showPassword,
                            onFieldSubmitted: (value) {
                              if (_formKey.currentState.validate()) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _loginPressed();
                              }
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Tolong masukan password anda.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey[100],
                              filled: true,
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 24.0,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                  size: 22.0,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(32.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 32.0),
                          FlatButton(
                            color: primaryColor,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _loginPressed();
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32.0)),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,
                              ),
                              alignment: Alignment.center,
                              width: 240.0,
                              child: _connectionProgres
                                  ? SpinKitThreeBounce(
                                      color: Colors.white,
                                      size: 16.0,
                                    )
                                  : Text(
                                      'Masuk',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            _errorMessage ?? '',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
