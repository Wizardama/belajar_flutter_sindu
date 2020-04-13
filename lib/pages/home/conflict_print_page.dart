import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/laporan_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ConlfictPrintPage extends StatefulWidget {
  final String uid;

  ConlfictPrintPage({@required this.uid});

  @override
  _ConlfictPrintPageState createState() => _ConlfictPrintPageState();
}

class _ConlfictPrintPageState extends State<ConlfictPrintPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();
  String _selectedWilayah;

  bool _connectionProgres = true;

  // Form
  final _formKey = GlobalKey<FormState>();
  final _tanggalFormat = DateFormat("yyyy-MM-dd HH:mm");
  TextEditingController _nomor = TextEditingController();
  TextEditingController _sumberInfo = TextEditingController();
  TextEditingController _hubunganDenganSumber = TextEditingController();
  TextEditingController _caraMendapatkanInfo = TextEditingController();
  TextEditingController _tanggal = TextEditingController();
  TextEditingController _nilaiInfo = TextEditingController();
  TextEditingController _perihal = TextEditingController();
  TextEditingController _langkahIntelijen = TextEditingController();

  // get url laporan
  void _getUrlLaporan(Map body) {
    print('called');
    _api
        .postLaporanURL(token: _loginModel.token, body: body, uid: widget.uid)
        .then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print(response.body);
        if (_selectedWilayah == 'Infosus') {
          print('${data['laporan_infosus']}');

          setState(() {
            _connectionProgres = false;
          });

          _launchURL('${data['laporan_infosus']}');
        } else {
          print('${data['laporan_li']}');

          setState(() {
            _connectionProgres = false;
          });

          _launchURL('${data['laporan_li']}');
        }
      } else {
        print(response.body);

        setState(() {
          _connectionProgres = false;
        });
      }
    });
  }

  void _getLaporanDetail() {
    _api
        .getLaporanDetail(token: _loginModel.token, uid: widget.uid)
        .then((response) {
      if (response.statusCode == 200) {
        LaporanModel laporan;
        try {
          laporan = LaporanModel.fromJson(response.body);
        } catch (e) {
          print(e.toString());
        }

        setState(() {
          _connectionProgres = false;

          _nomor.text = laporan.nomor;
          _sumberInfo.text = laporan.sumberInformasi;
          _hubunganDenganSumber.text = laporan.hubunganDenganSumber;
          _caraMendapatkanInfo.text = laporan.caraMendapatkanInformasi;
          _tanggal.text = laporan.waktuMendapatkanInformasi;
          _nilaiInfo.text = laporan.nilaiInformasi;
          _perihal.text = laporan.perihal;
          _langkahIntelijen.text = laporan.langkahIntelijen;
        });
      }
    }).catchError((error) {
      setState(() {
        _connectionProgres = false;
      });
    });
  }

  dynamic _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _getLaporanDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Cetak Laporan Konflik',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Wilayah:',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Wrap(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                child: ChoiceChip(
                                  label: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'LI',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  selected: _selectedWilayah == 'LI',
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedWilayah = 'LI';
                                    });
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                child: ChoiceChip(
                                  label: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Infosus',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  selected: _selectedWilayah == 'Infosus',
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedWilayah = 'Infosus';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          _selectedWilayah != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _selectedWilayah == 'LI'
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Nomor:',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextFormField(
                                                minLines: 1,
                                                maxLines: 6,
                                                controller: _nomor,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Tolong masukan nomor.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Sumber informasi:',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextFormField(
                                                minLines: 1,
                                                maxLines: 6,
                                                controller: _sumberInfo,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Tolong masukan sumber info.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Hubungan dengan sumber:',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextFormField(
                                                minLines: 1,
                                                maxLines: 6,
                                                controller:
                                                    _hubunganDenganSumber,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Tolong masukan hubungan dengan sumber.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Cara mendapatkan informasi:',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextFormField(
                                                minLines: 1,
                                                maxLines: 6,
                                                controller:
                                                    _caraMendapatkanInfo,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Tolong masukan cara mendapatkan info.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Tanggal:',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              DateTimeField(
                                                controller: _tanggal,
                                                format: _tanggalFormat,
                                                onShowPicker:
                                                    (context, currentValue) {
                                                  return showDatePicker(
                                                    context: context,
                                                    firstDate: DateTime(1900),
                                                    initialDate: currentValue ??
                                                        DateTime.now(),
                                                    lastDate: DateTime(2100),
                                                  );
                                                },
                                                validator: (value) {
                                                  if (value == null &&
                                                      _tanggal.text == null) {
                                                    return 'Tolong masukan tangal.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Nilai informasi:',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextFormField(
                                                minLines: 1,
                                                maxLines: 6,
                                                controller: _nilaiInfo,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Tolong masukan nilai info.';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16.0),
                                            ],
                                          )
                                        : Container(),
                                    Text(
                                      'Perihal:',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 6,
                                      controller: _perihal,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Tolong masukan perihal.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Langkah Intelijen:',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 6,
                                      controller: _langkahIntelijen,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Tolong masukan langkah-langkah.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 24.0),
                                    FlatButton(
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          setState(() {
                                            _connectionProgres = true;
                                          });
                                          if (_selectedWilayah == 'Infosus') {
                                            // print(
                                            //   {
                                            //     'perihal': _perihal.text,
                                            //     'langkah_intelijen':
                                            //         _langkahIntelijen.text,
                                            //   },
                                            // );

                                            /* kalo sudah  difix make ini */
                                            // _getUrlLaporan({
                                            //   'perihal': _perihal.text,
                                            //   'langkah_intelijen':
                                            //       _langkahIntelijen.text,
                                            // });
                                            /* kalo belum difix */
                                            _getUrlLaporan({
                                              'nomor': _nomor.text,
                                              'sumber_informasi':
                                                  _sumberInfo.text,
                                              'hubungan_dgn_sumber':
                                                  _hubunganDenganSumber.text,
                                              'cara_mendapatkan_informasi':
                                                  _caraMendapatkanInfo.text,
                                              'waktu_mendapatkan_informasi':
                                                  _tanggal.text,
                                              'nilai_informasi':
                                                  _nilaiInfo.text,
                                              'perihal': _perihal.text,
                                              'langkah_intelijen':
                                                  _langkahIntelijen.text,
                                            });
                                          } else {
                                            // print(
                                            //   {
                                            //     'nomor': _nomor.text,
                                            //     'sumber_informasi':
                                            //         _sumberInfo.text,
                                            //     'hubungan_dgn_sumber':
                                            //         _hubunganDenganSumber.text,
                                            //     'cara_mendapatkan_informasi':
                                            //         _caraMendapatkanInfo.text,
                                            //     'waktu_mendapatkan_informasi':
                                            //         _langkahIntelijen.text,
                                            //     'nilai_informasi':
                                            //         _nilaiInfo.text,
                                            //     'perihal': _perihal.text,
                                            //     'langkah_intelijen':
                                            //         _langkahIntelijen.text,
                                            //   },
                                            // );
                                            _getUrlLaporan({
                                              'nomor': _nomor.text,
                                              'sumber_informasi':
                                                  _sumberInfo.text,
                                              'hubungan_dgn_sumber':
                                                  _hubunganDenganSumber.text,
                                              'cara_mendapatkan_informasi':
                                                  _caraMendapatkanInfo.text,
                                              'waktu_mendapatkan_informasi':
                                                  _tanggal.text,
                                              'nilai_informasi':
                                                  _nilaiInfo.text,
                                              'perihal': _perihal.text,
                                              'langkah_intelijen':
                                                  _langkahIntelijen.text,
                                            });
                                          }
                                        }
                                      },
                                      color: Colors.red,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 16.0,
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.file_download,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            SizedBox(width: 12.0),
                                            Text(
                                              'Unduh laporan',
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
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        _connectionProgres
            ? Container(
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
              )
            : Container(),
      ],
    );
  }
}
