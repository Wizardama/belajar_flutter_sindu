import 'package:cached_network_image/cached_network_image.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/konflik_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/pages/home/conflict_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ConlfictDetailPage extends StatefulWidget {
  final Function refresh;
  final String uid;
  final bool noAction;

  ConlfictDetailPage(
      {@required this.refresh, @required this.uid, this.noAction = false});

  @override
  _ConlfictDetailPageState createState() => _ConlfictDetailPageState();
}

class _ConlfictDetailPageState extends State<ConlfictDetailPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();

  Future<http.Response> _futureConflict;

  bool _connectionProgres = false;

  void _jumpToPage({Widget page}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  dynamic _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _setConflictDelete() {
    setState(() {
      _connectionProgres = true;
    });

    print('uwuu');
    _api
        .getKonflikDelete(token: _loginModel.token, uid: widget.uid)
        .then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          _connectionProgres = false;
        });

        if (widget.refresh != null) {
          widget.refresh();
        }

        Navigator.pop(context);
      } else {
        setState(() {
          _connectionProgres = false;
        });
      }
    }).catchError((error) {
      print(error.toString());
      setState(() {
        _connectionProgres = false;
      });
    });
  }

  void _showDialog({
    @required String message,
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
                _setConflictDelete();
                Navigator.pop(context, true);
              },
              child: Text('Ya, benar'),
            )
          ],
        );
      },
    );
  }

  _reloadData() {
    widget.refresh();
    _futureConflict =
        _api.getKonflikDetail(token: _loginModel.token, uid: widget.uid);
  }

  @override
  void initState() {
    super.initState();
    _futureConflict =
        _api.getKonflikDetail(token: _loginModel.token, uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Detail Potensi',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        actions: widget.noAction
            ? <Widget>[]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _jumpToPage(
                      page: ConlfictEditPage(
                          refresh: _reloadData, uid: widget.uid),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDialog(
                      message: 'Hapus data potensi ini?',
                    );
                  },
                ),
              ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context).copyWith(
      accentColor: Colors.black87,
      dividerColor: Colors.transparent,
    );

    return Stack(
      children: <Widget>[
        Container(
          child: FutureBuilder(
            future: _futureConflict,
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
                      KonflikDetailModel konflik =
                          KonflikDetailModel.fromJson(snapshot.data.body);

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Card(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${konflik.judul}',
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
                                      'Jenis:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      konflik.jenis == 1
                                          ? 'Kejadian Menonjol'
                                          : 'Potensi Konflik',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Wilayah:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '${konflik.namaWilayah}',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Bidang:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '${konflik.bidang}',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Kategori:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '${konflik.kategori}',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Waktu potensi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '${konflik.waktuPotensiKonflik}',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Uraian potensi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    // Text(
                                    //   '${konflik.uraianPotensiKonflik}',
                                    //   style: const TextStyle(
                                    //     fontSize: 15.0,
                                    //     fontWeight: FontWeight.w600,
                                    //   ),
                                    // ),
                                    HtmlWidget(
                                        '${konflik.uraianPotensiKonflik}'),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Analisa:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    // Text(
                                    //   '${konflik.analisa}',
                                    //   style: const TextStyle(
                                    //     fontSize: 15.0,
                                    //     fontWeight: FontWeight.w600,
                                    //   ),
                                    // ),
                                    HtmlWidget('${konflik.analisa}'),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Prediksi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    // Text(
                                    //   '${konflik.prediksi}',
                                    //   style: const TextStyle(
                                    //     fontSize: 15.0,
                                    //     fontWeight: FontWeight.w600,
                                    //   ),
                                    // ),
                                    HtmlWidget('${konflik.prediksi}'),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Rekomendasi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    // Text(
                                    //   '${konflik.rekomendasi}',
                                    //   style: const TextStyle(
                                    //     fontSize: 15.0,
                                    //     fontWeight: FontWeight.w600,
                                    //   ),
                                    // ),
                                    HtmlWidget('${konflik.rekomendasi}'),
                                    SizedBox(height: 16.0),
                                    Divider(color: Colors.grey[400]),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Dokumentasi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    _listDokumen(konflik.listDokPotensi),
                                    SizedBox(height: 16.0),
                                    Divider(color: Colors.grey[400]),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Status penanggulangan:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      konflik.statusPenanggulangan == 1
                                          ? 'Tertangani'
                                          : 'Belum',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            konflik.penanganan != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      border: Border.all(
                                        color: Colors.grey[400],
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Theme(
                                          data: theme,
                                          child: ExpansionTile(
                                            title: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Penanganan',
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Fakta:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    // Text(
                                                    //   '${konflik.penanganan.fakta}',
                                                    //   style: const TextStyle(
                                                    //     fontSize: 15.0,
                                                    //     fontWeight:
                                                    //         FontWeight.w600,
                                                    //   ),
                                                    // ),
                                                    HtmlWidget(
                                                        '${konflik.penanganan.fakta}'),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Keterangan:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    // Text(
                                                    //   '${konflik.penanganan.keterangan}',
                                                    //   style: const TextStyle(
                                                    //     fontSize: 15.0,
                                                    //     fontWeight:
                                                    //         FontWeight.w600,
                                                    //   ),
                                                    // ),
                                                    HtmlWidget(
                                                        '${konflik.penanganan.keterangan}'),
                                                    SizedBox(height: 16.0),
                                                    Divider(
                                                        color:
                                                            Colors.grey[400]),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Dokumentasi:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    _listDokumen(konflik
                                                        .listDokPenanganan),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16.0),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 16.0),
                            konflik.laporan != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      border: Border.all(
                                        color: Colors.grey[400],
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Theme(
                                          data: theme,
                                          child: ExpansionTile(
                                            title: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'LI & Infosus',
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Nomor:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.nomor}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Sumber informasi:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.sumberInformasi}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Hubungan dengan sumber:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.hubunganDenganSumber}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Cara mendapatkan informasi:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.caraMendapatkanInformasi}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Waktu mendapatkan informasi:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.waktuMendapatkanInformasi}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Nilai informasi:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.caraMendapatkanInformasi}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Perihal:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.perihal}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                      'Langkah Intelijen:',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Text(
                                                      '${konflik.laporan.langkahIntelijen}',
                                                      style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16.0),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
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

  Widget _listDokumen(List<DokumenKonflikModel> dokumens) {
    if (dokumens.length > 0) {
      return Container(
        padding: EdgeInsets.only(top: 8.0),
        child: Wrap(
          children: dokumens.map((f) {
            return Container(
              height: 120.0,
              width: 120.0,
              child: f.type == 'PDF'
                  ? GestureDetector(
                      child: Container(
                        margin: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                            ),
                            SizedBox(height: 12.0),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${f.filename}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        await _launchURL(f.location);
                      },
                    )
                  : GestureDetector(
                      child: Container(
                        margin: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          color: Colors.white,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: f.location,
                          fit: BoxFit.cover,
                        ),
                      ),
                      onTap: () async {
                        await _launchURL(f.location);
                      },
                    ),
            );
          }).toList(),
        ),
      );
    } else {
      return Container(
        child: Text(
          'Belum atau tidak ada dokumentasi.',
          style: TextStyle(color: Colors.red, fontSize: 12.0),
        ),
      );
    }
  }
}
