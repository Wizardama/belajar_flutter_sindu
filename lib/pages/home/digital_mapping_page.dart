import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/konflik_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/widgets/filter_sheet_widget.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/peta_model.dart';
import 'package:digimap_pandonga/pages/home/digital_mapping_info_bidang_page.dart';
import 'package:digimap_pandonga/pages/home/conflict_add_page.dart';
import 'package:digimap_pandonga/pages/home/conflict_detail_page.dart';
import 'package:digimap_pandonga/pages/home/conflict_print_page.dart';

// Ext
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong/latlong.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

const tokenPeta =
    'pk.eyJ1Ijoid2l6YXJkYW1hIiwiYSI6ImNrNzV5NTNjZDExeGgzZHFrNGU5Z3V2YW8ifQ.cfhMLIPZYqKqGwRI1Eqz8Q';

class DigitalMappingPage extends StatefulWidget {
  @override
  _DigitalMappingPageState createState() => _DigitalMappingPageState();
}

class _DigitalMappingPageState extends State<DigitalMappingPage>
    with SingleTickerProviderStateMixin {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();
  TabController _tabController;

  void _jumpToPage({Widget page}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Filter
  bool _switchTerkini = false;
  int _wilayahActive;
  int _bidangActive;
  int _kategoriActive;
  int _jenisActive;

  void _setFilter(int wilayah, int bidang, int kategori, int jenis) {
    setState(() {
      // Atur ulang future list kalo beda idnya
      if (wilayah != _wilayahActive ||
          bidang != _bidangActive ||
          kategori != _kategoriActive ||
          jenis != _jenisActive) {
        _futureListData = _api.getKonflikData(
          token: _loginModel.token,
          wilayah: wilayah,
          bidang: bidang,
          kategori: kategori,
          jenis: jenis,
          terkini: _switchTerkini,
        );
      }

      _wilayahActive = wilayah;
      _bidangActive = bidang;
      _kategoriActive = kategori;
      _jenisActive = jenis;

      // Tutup info map window
      _informationWindow = false;

      if (_petas != null) {
        List<PetaModel> newList =
            _petas.list.where((f) => f.id == wilayah).toList();

        if (newList.length > 0) {
          _selectedPeta = newList[0];
        } else {
          _selectedPeta = null;
        }
      }
    });
  }

  void _showFilter(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterSheetWidget(
          wilayahValue: _wilayahActive,
          bidangValue: _bidangActive,
          kategoriValue: _kategoriActive,
          jenisValue: _jenisActive,
          filterFunction: _setFilter,
        );
      },
    );
  }

  // Map
  MarkerLayerOptions _markerLayerOptions;
  PetaModels _petas;
  PetaModel _selectedPeta;

  bool _connectionProgresMarker = true;
  bool _informationWindow = false;
  bool _switchToMenonjol = false;

  void _showMarker({bool terkini = false}) {
    _api
        .getMapData(token: _loginModel.token, terkini: terkini)
        .then((response) {
      if (response.statusCode == 200) {
        _petas = PetaModels.fromJson(response.body);
        List<Marker> markers = new List();

        _petas.list.forEach((f) {
          markers.add(
            Marker(
              height: 28.0,
              width: 28.0,
              point: f.latLng,
              builder: (context) => GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      border: Border.all(
                        width: 2.0,
                        color: Colors.white,
                      )),
                  child: Text(
                    '${f.total}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    // Atur ulang future list kalo beda idnya
                    if (f.id != _wilayahActive) {
                      _futureListData = _api.getKonflikData(
                        token: _loginModel.token,
                        wilayah: f.id,
                        bidang: _bidangActive,
                        kategori: _kategoriActive,
                        jenis: _jenisActive,
                        terkini: _switchTerkini,
                      );
                    }

                    _selectedPeta = f;
                    _informationWindow = true;
                    _wilayahActive = f.id;
                  });
                },
              ),
            ),
          );
        });

        setState(() {
          _connectionProgresMarker = false;
          _markerLayerOptions = MarkerLayerOptions(
            markers: markers,
          );

          if (_selectedPeta == null) {
            _selectedPeta = _petas.list[0];
            _wilayahActive = _petas.list[0].id;
          }
        });
      } else {
        //
        setState(() {
          _connectionProgresMarker = false;
        });
      }
    }).catchError((error) {
      // Catch error
      setState(() {
        _connectionProgresMarker = false;
      });
    });
  }

  // List
  Future<http.Response> _futureListData;

  void _refreshListData() {
    setState(() {
      _futureListData = _api.getKonflikData(
        token: _loginModel.token,
        wilayah: _wilayahActive,
        bidang: _wilayahActive,
        kategori: _kategoriActive,
        jenis: _jenisActive,
        terkini: _switchTerkini,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Marker
    _markerLayerOptions = MarkerLayerOptions();
    _showMarker();

    // List
    _futureListData = _api.getKonflikData(token: _loginModel.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Digital Mapping',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Peta',
            ),
            Tab(
              text: 'Grafik',
            ),
            Tab(
              text: 'Data',
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _jumpToPage(page: ConlfictAddPage(refresh: _refreshListData));
              })
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
      controller: _tabController,
      children: [
        _petaBody(),
        _grafikBody(),
        _listBody(),
      ],
    );
  }

  Widget _petaBody() {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      Text('Tampilkan data terkini?'),
                      Text(
                        _selectedPeta != null
                            ? '${_selectedPeta.namaWilayah}'
                            : '-',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
                Switch(
                  value: _switchTerkini,
                  onChanged: (bool value) {
                    setState(() {
                      _switchTerkini = !_switchTerkini;

                      _futureListData = _api.getKonflikData(
                        token: _loginModel.token,
                        wilayah: _wilayahActive,
                        bidang: _bidangActive,
                        kategori: _kategoriActive,
                        jenis: _jenisActive,
                        terkini: _switchTerkini,
                      );

                      _showMarker(terkini: _switchTerkini);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: () {
                    _showFilter(context);
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(-7.0051, 110.4381),
                      zoom: 8.0,
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/rajayogan/cjl1bndoi2na42sp2pfh2483p/tiles/256/{z}/{x}/{y}@2x?access_token=$tokenPeta',
                        tileProvider: CachedNetworkTileProvider(),
                        additionalOptions: {
                          'accessToken': tokenPeta,
                          'id': 'mapbox.mapbox-streets-v7',
                        },
                      ),
                      _markerLayerOptions,
                    ],
                  ),
                ),
                AnimatedPositioned(
                  bottom: _informationWindow ? 16.0 : -160,
                  left: 16.0,
                  right: 16.0,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 160.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              right: 16.0,
                              child: IconButton(
                                icon: Icon(Icons.close),
                                tooltip: 'Tutup jendela',
                                onPressed: () {
                                  setState(() {
                                    _informationWindow = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: _selectedPeta != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 16.0),
                                  Container(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      '${_selectedPeta.namaWilayah}',
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        ChoiceChip(
                                          selected: !_switchToMenonjol,
                                          selectedColor: Colors.red,
                                          label: Text(
                                            'P. Konflik',
                                            style: TextStyle(
                                              color: _switchToMenonjol
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                          ),
                                          onSelected: (value) {
                                            setState(() {
                                              _switchToMenonjol = false;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 8.0),
                                        ChoiceChip(
                                          selected: _switchToMenonjol,
                                          selectedColor: Colors.red,
                                          label: Text(
                                            'K. Menonjol',
                                            style: TextStyle(
                                              color: _switchToMenonjol
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          onSelected: (value) {
                                            setState(() {
                                              _switchToMenonjol = true;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Container(
                                    width: double.infinity,
                                    height: 56.0,
                                    child: ScrollConfiguration(
                                      behavior: ScrollBlankBehavior(),
                                      child: _listInfoPeta(),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      )
                    ],
                  ),
                  duration: Duration(
                    milliseconds: 100,
                  ),
                ),
                _connectionProgresMarker
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _listInfoPeta() {
    return Scrollbar(
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: _selectedPeta.dataBidang.length,
        itemBuilder: (BuildContext context, int index) {
          BidangPetaModel bidang = _selectedPeta.dataBidang[index];
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            width: 64.0,
            child: Column(
              children: <Widget>[
                Text(
                  _switchToMenonjol
                      ? '${bidang.totalMenonjol}'
                      : '${bidang.totalPotensi}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${bidang.namaBidang}',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _grafikBody() {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      Text('Tampilkan data terkini?'),
                      Text(
                        _selectedPeta != null
                            ? '${_selectedPeta.namaWilayah}'
                            : '-',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
                Switch(
                  value: _switchTerkini,
                  onChanged: (bool value) {
                    setState(() {
                      _switchTerkini = !_switchTerkini;

                      _futureListData = _api.getKonflikData(
                        token: _loginModel.token,
                        wilayah: _wilayahActive,
                        bidang: _bidangActive,
                        kategori: _kategoriActive,
                        jenis: _jenisActive,
                        terkini: _switchTerkini,
                      );

                      _showMarker(terkini: _switchTerkini);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: () {
                    _showFilter(context);
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: _selectedPeta == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Anda belum memilih wilayah.'),
                      SizedBox(height: 16.0),
                      ActionChip(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        avatar: Icon(
                          Icons.tune,
                          size: 20.0,
                        ),
                        label: Text('Pilih wilayah'),
                        onPressed: () {
                          _showFilter(context);
                        },
                      )
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(8.0),
                          height: 280,
                          child: charts.BarChart(
                            _createGrafikData(peta: _selectedPeta),
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
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    Divider(height: 1.0),
                            itemCount: _selectedPeta.dataBidang.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Column(
                                  children: <Widget>[
                                    SizedBox(height: 16.0),
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
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
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
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.fade,
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
                                    GestureDetector(
                                      child: Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 16.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 8,
                                              child: Text(
                                                '${_selectedPeta.dataBidang[index].namaBidang}',
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                '${_selectedPeta.dataBidang[index].totalMenonjol}',
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
                                                '${_selectedPeta.dataBidang[index].totalPotensi}',
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
                                      onTap: () {
                                        _jumpToPage(
                                            page: DigitalMappingInfoBidang(
                                          wilayahId: _wilayahActive,
                                          bidangs: _selectedPeta.dataBidang,
                                          wilayahName:
                                              _selectedPeta.namaWilayah,
                                          bidangId: _selectedPeta
                                              .dataBidang[index].id,
                                        ));
                                      },
                                    ),
                                  ],
                                );
                              } else {
                                return GestureDetector(
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 16.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 8,
                                          child: Text(
                                            '${_selectedPeta.dataBidang[index].namaBidang}',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            '${_selectedPeta.dataBidang[index].totalMenonjol}',
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
                                            '${_selectedPeta.dataBidang[index].totalPotensi}',
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
                                  onTap: () {
                                    _jumpToPage(
                                        page: DigitalMappingInfoBidang(
                                      wilayahId: _wilayahActive,
                                      bidangs: _selectedPeta.dataBidang,
                                      wilayahName: _selectedPeta.namaWilayah,
                                      bidangId:
                                          _selectedPeta.dataBidang[index].id,
                                    ));
                                  },
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _listBody() {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      Text('Tampilkan data terkini?'),
                      Text(
                        _selectedPeta != null
                            ? '${_selectedPeta.namaWilayah}'
                            : '-',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
                Switch(
                  value: _switchTerkini,
                  onChanged: (bool value) {
                    setState(() {
                      setState(() {
                        _switchTerkini = !_switchTerkini;

                        _futureListData = _api.getKonflikData(
                          token: _loginModel.token,
                          wilayah: _wilayahActive,
                          bidang: _bidangActive,
                          kategori: _kategoriActive,
                          jenis: _jenisActive,
                          terkini: _switchTerkini,
                        );

                        _showMarker(terkini: _switchTerkini);
                      });
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: () {
                    _showFilter(context);
                  },
                )
              ],
            ),
          ),
          Expanded(
            // child: _selectedPeta == null
            //     ? Container(
            //         child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: <Widget>[
            //           Text('Anda belum memilih wilayah.'),
            //           SizedBox(height: 16.0),
            //           ActionChip(
            //             padding: EdgeInsets.symmetric(
            //               horizontal: 16.0,
            //               vertical: 8.0,
            //             ),
            //             avatar: Icon(
            //               Icons.tune,
            //               size: 20.0,
            //             ),
            //             label: Text('Pilih wilayah'),
            //             onPressed: () {
            //               _showFilter(context);
            //             },
            //           )
            //         ],
            //       ))
            //     : Container(
            //         child: _futureListKonflik(),
            //       ),
            child: Container(
              child: _futureListKonflik(),
            ),
          )
        ],
      ),
    );
  }

  Widget _futureListKonflik() {
    return FutureBuilder(
      future: _futureListData,
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
            );
          case ConnectionState.done:
            if (snapshot.hasData) {
              if (snapshot.data.statusCode == 200) {
                KonflikModels konfliks =
                    KonflikModels.fromJson(snapshot.data.body);
                return _listKonflikData(konfliks: konfliks);
              } else {
                // if not 200
              }
            } else if (snapshot.hasError) {}
        }
        return Container();
      },
    );
  }

  Widget _listKonflikData({
    @required KonflikModels konfliks,
  }) {
    if (konfliks.list.length > 0) {
      return Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: konfliks.list.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Card(
                    margin: EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 64.0,
                                width: 64.0,
                                color: Colors.red,
                                child: konfliks.list[index].location != null
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            '${konfliks.list[index].location}',
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${konfliks.list[index].judul}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          '${konfliks.list[index].jenis}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        konfliks.list[index].jenis ==
                                                'Kejadian Menonjol'
                                            ? Icon(
                                                Icons.flash_on,
                                                size: 16.0,
                                                color: Colors.red,
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    Text(
                                      '${konfliks.list[index].namaWilayah}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        'BIDANG',
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                          '${konfliks.list[index].namaBidang}'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        'KATEGORI',
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                          '${konfliks.list[index].namaKategori}'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'STATUS',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '${konfliks.list[index].statusPenanganan}',
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: konfliks.list[index]
                                                                .statusPenanganan ==
                                                            'Tertangani'
                                                        ? Colors.green
                                                        : Colors.red),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.print),
                                    onPressed: () {
                                      _jumpToPage(
                                        page: ConlfictPrintPage(
                                          uid: konfliks.list[index].uid,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    _jumpToPage(
                      page: ConlfictDetailPage(
                        refresh: _refreshListData,
                        uid: konfliks.list[index].uid,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.8, color: Colors.grey[300]),
              ),
              color: Colors.white,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 8.0,
                    ),
                    onPressed: konfliks.currentPage == 1
                        ? null
                        : () {
                            setState(() {
                              _futureListData = _api.getKonflikData(
                                token: _loginModel.token,
                                wilayah: _wilayahActive,
                                bidang: _bidangActive,
                                kategori: _kategoriActive,
                                jenis: _jenisActive,
                                page: konfliks.currentPage - 1,
                                terkini: _switchTerkini,
                              );
                            });
                          },
                    child: Text('Sebelumnya'),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${konfliks.currentPage} / ${konfliks.lastPage}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 8.0,
                    ),
                    onPressed: konfliks.currentPage == konfliks.lastPage
                        ? null
                        : () {
                            setState(() {
                              _futureListData = _api.getKonflikData(
                                token: _loginModel.token,
                                wilayah: _wilayahActive,
                                bidang: _bidangActive,
                                kategori: _kategoriActive,
                                jenis: _jenisActive,
                                page: konfliks.currentPage + 1,
                                terkini: _switchTerkini,
                              );
                            });
                          },
                    child: Text('Selanjutnya'),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createGrafikData({
    PetaModel peta,
  }) {
    List<OrdinalSales> listPotensi = new List();
    List<OrdinalSales> listMenonjol = new List();

    peta.dataBidang.forEach((f) {
      listPotensi.add(OrdinalSales(f.namaBidang, f.totalPotensi));
      listMenonjol.add(OrdinalSales(f.namaBidang, f.totalMenonjol));
    });

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'P. Konflik',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: listPotensi,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'K. Menonjol',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: listMenonjol,
        fillPatternFn: (OrdinalSales sales, _) =>
            charts.FillPatternType.forwardHatch,
      ),
    ];
  }
}

class ScrollBlankBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
