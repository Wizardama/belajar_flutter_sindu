import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/models/peta_model.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/kounter_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';

// Ext
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DigitalMappingInfoBidang extends StatefulWidget {
  final List<BidangPetaModel> bidangs;
  final int bidangId;
  final int wilayahId;
  final String wilayahName;

  DigitalMappingInfoBidang({
    @required this.bidangs,
    @required this.wilayahId,
    @required this.bidangId,
    @required this.wilayahName,
  });

  @override
  _DigitalMappingInfoBidangState createState() =>
      _DigitalMappingInfoBidangState();
}

class _DigitalMappingInfoBidangState extends State<DigitalMappingInfoBidang> {
  // Filter
  int _bidangActive;
  int _currentIndex;
  BidangPetaModel _selectedBidang;

  API _api = API();
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);

  Future<http.Response> _futureBidang;

  @override
  void initState() {
    super.initState();

    // Initial value
    _bidangActive = widget.bidangId;

    _futureBidang = _api.getKounterData(
      token: _loginModel.token,
      idWilayah: widget.wilayahId,
      idBidang: widget.bidangId,
    );

    _futureBidang.then((response) {
      print(response.statusCode);
    });

    List<BidangPetaModel> newList =
        widget.bidangs.where((f) => f.id == _bidangActive).toList();

    if (newList.length > 0) {
      _currentIndex = widget.bidangs.indexOf(newList[0]);
      _selectedBidang = newList[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Info Detail Bidang',
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
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (_currentIndex >= 1) {
                      setState(() {
                        _currentIndex--;
                        _selectedBidang = widget.bidangs[_currentIndex];

                        _futureBidang = _api.getKounterData(
                          token: _loginModel.token,
                          idWilayah: widget.wilayahId,
                          idBidang: _currentIndex,
                        );
                      });
                    } else if (_currentIndex == 0) {
                      setState(() {
                        _currentIndex = widget.bidangs.length - 1;
                        _selectedBidang = widget.bidangs[_currentIndex];

                        _futureBidang = _api.getKounterData(
                          token: _loginModel.token,
                          idWilayah: widget.wilayahId,
                          idBidang: _currentIndex,
                        );
                      });
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      Text('${widget.wilayahName}'),
                      Text(
                        '${_selectedBidang.namaBidang}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    if (_currentIndex < widget.bidangs.length - 1) {
                      setState(() {
                        _currentIndex++;
                        _selectedBidang = widget.bidangs[_currentIndex];

                        _futureBidang = _api.getKounterData(
                          token: _loginModel.token,
                          idWilayah: widget.wilayahId,
                          idBidang: _currentIndex,
                        );
                      });
                    } else if (_currentIndex == widget.bidangs.length - 1) {
                      setState(() {
                        _currentIndex = 0;
                        _selectedBidang = widget.bidangs[_currentIndex];

                        _futureBidang = _api.getKounterData(
                          token: _loginModel.token,
                          idWilayah: widget.wilayahId,
                          idBidang: _currentIndex,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _futureBidang,
              builder: (BuildContext context,
                  AsyncSnapshot<http.Response> snapshot) {
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
                        KounterModels kounters =
                            KounterModels.fromJson(snapshot.data.body);

                        return ListView(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              height: 400,
                              child: charts.BarChart(
                                _createSampleData(kounters),
                                animate: true,
                                barGroupingType: charts.BarGroupingType.grouped,
                                vertical: false,
                                behaviors: [
                                  charts.SeriesLegend(
                                    position: charts.BehaviorPosition.bottom,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 8,
                                    child: Container(),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'K. Menonjol',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'P. Konflik',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1.0),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: kounters.list.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 8,
                                        child: Container(
                                          child: Text(
                                            '${kounters.list[index].nama}',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          '${kounters.list[index].totalMenonjol}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          '${kounters.list[index].totalPotensi}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        );
                      }
                    }
                }
                return Container();
              },
            ),
          )
        ],
      ),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData(
      KounterModels kounters) {
    List<OrdinalSales> listPotensi = new List();
    List<OrdinalSales> listMenonjol = new List();

    kounters.list.forEach((f) {
      listPotensi.add(OrdinalSales(f.nama, f.totalPotensi));
      listMenonjol.add(OrdinalSales(f.nama, f.totalMenonjol));
    });

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'K. Menonjol',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: listMenonjol,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'P. Konflik',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: listPotensi,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
