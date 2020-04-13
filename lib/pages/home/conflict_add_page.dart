import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/filter_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ConlfictAddPage extends StatefulWidget {
  final Function refresh;

  ConlfictAddPage({@required this.refresh});

  @override
  _ConlfictAddPageState createState() => _ConlfictAddPageState();
}

class _ConlfictAddPageState extends State<ConlfictAddPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();

  bool _connectionProgres = false;

  void _addFile({bool isImage = false, bool isPotensi = false}) async {
    File file;

    if (isImage) {
      file = await FilePicker.getFile(type: FileType.image);

      if (file != null) {
        setState(() {
          if (isPotensi) {
            _listFileFoto.add(file);
          } else {
            _listPenFileFoto.add(file);
          }
        });
      }
    } else {
      file = await FilePicker.getFile(
          type: FileType.custom, allowedExtensions: ['pdf']);

      if (file != null) {
        setState(() {
          if (isPotensi) {
            _listFilePDF.add(file);
          } else {
            _listPenFilePDF.add(file);
          }
        });
      }
    }
  }

  // Form
  final _formKey = GlobalKey<FormState>();
  final _tanggalFormat = DateFormat("yyyy-MM-dd HH:mm");
  TextEditingController _judul = TextEditingController();
  String _selectedJenis = 'Kejadian Menonjol';
  String _selectedStatus = 'Belum';
  int _selectedWilayah;
  int _selectedBidang;
  int _selectedKategori;
  TextEditingController _tanggalPotensi = TextEditingController();
  TextEditingController _uraian = TextEditingController();
  TextEditingController _analisa = TextEditingController();
  TextEditingController _prediksi = TextEditingController();
  TextEditingController _rekomendasi = TextEditingController();
  List<File> _listFileFoto = new List();
  List<File> _listFilePDF = new List();

  // Form Part 2 Penanganan
  TextEditingController _fakta = TextEditingController();
  TextEditingController _keterangan = TextEditingController();
  TextEditingController _catatan = TextEditingController();
  List<File> _listPenFileFoto = new List();
  List<File> _listPenFilePDF = new List();

  // Form Part 3 LI & Infosus
  TextEditingController _nomor = TextEditingController();
  TextEditingController _sumberInfo = TextEditingController();
  TextEditingController _hubunganDenganSumber = TextEditingController();
  TextEditingController _caraMendapatkanInfo = TextEditingController();
  TextEditingController _tanggal = TextEditingController();
  TextEditingController _nilaiInfo = TextEditingController();
  TextEditingController _perihal = TextEditingController();
  TextEditingController _langkahIntelijen = TextEditingController();

  // get url laporan
  void _postAddKonflik() {
    _api
        .postKonflikAdd(
      token: _loginModel.token,
      judul: _judul.text,
      jenis: _selectedJenis == 'K. Menonjol' ? 1 : 0,
      idWilayah: _selectedWilayah,
      idBidang: _selectedBidang,
      idKategori: _selectedKategori,
      waktuPotensiKonflik: _tanggalPotensi.text,
      uraian: _uraian.text,
      prediksi: _prediksi.text,
      rekomendasi: _rekomendasi.text,
      analisa: _analisa.text,
      status: _selectedStatus == 'Tertangani' ? 1 : 0,
      potensiFoto: _listFileFoto,
      potensiDoc: _listFilePDF,

      //
      fakta: _fakta.text,
      keterangan: _keterangan.text,
      catatan: _catatan.text,
      penangananFoto: _listPenFileFoto,
      penangananDoc: _listPenFilePDF,

      //
      nomor: _nomor.text,
      sumberInformasi: _sumberInfo.text,
      hubunganDgnSumber: _hubunganDenganSumber.text,
      caraMendapatkanInfo: _caraMendapatkanInfo.text,
      waktuMendapatkanInfo: _tanggal.text,
      nilaiInformasi: _nilaiInfo.text,
      perihal: _perihal.text,
      langkahIntelijen: _langkahIntelijen.text,
    )
        .then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        widget.refresh();

        Toast.show("Data Berhasil tersimpan", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

        setState(() {
          _connectionProgres = false;
        });

        Navigator.pop(context);
      } else {
        print(response.body);

        setState(() {
          _connectionProgres = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Tambah Potensi',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
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
                            'Judul:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            minLines: 1,
                            maxLines: 2,
                            controller: _judul,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Tolong masukan judul.';
                              }
                              return null;
                            },
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
                          Wrap(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                child: ChoiceChip(
                                  label: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'K. Menonjol',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  selected: _selectedJenis == 'K. Menonjol',
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedJenis = 'K. Menonjol';
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
                                      'P. Konflik',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  selected: _selectedJenis == 'P. Konflik',
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedJenis = 'P. Konflik';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          _trioList(),
                          Text(
                            'Waktu potensi:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          DateTimeField(
                            controller: _tanggalPotensi,
                            format: _tanggalFormat,
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                            },
                            validator: (value) {
                              if (value == null &&
                                  _tanggalPotensi.text == null) {
                                return 'Tolong masukan tangal.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Uraian potensi:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            minLines: 1,
                            maxLines: 6,
                            controller: _uraian,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Tolong masukan uraian.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Analisa:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            minLines: 1,
                            maxLines: 6,
                            controller: _analisa,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Tolong masukan analisa.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Prediksi:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            minLines: 1,
                            maxLines: 6,
                            controller: _prediksi,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Tolong masukan prediksi.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Rekomendasi:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            minLines: 1,
                            maxLines: 6,
                            controller: _rekomendasi,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Tolong masukan rekomendasi.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          Divider(color: Colors.grey[400]),
                          SizedBox(height: 16.0),
                          Text(
                            'Dokumentasi foto:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          _listFileThumb(image: true, files: _listFileFoto),
                          FlatButton(
                            onPressed: () {
                              _addFile(isImage: true, isPotensi: true);
                            },
                            color: Colors.red[50],
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.add),
                                  Text('Tambah foto')
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Dokumentasi Dokumen:',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          _listFileThumb(image: false, files: _listFilePDF),
                          FlatButton(
                            onPressed: () {
                              _addFile(isImage: false, isPotensi: true);
                            },
                            color: Colors.red[50],
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.add),
                                  Text('Tambah dokumen')
                                ],
                              ),
                            ),
                          ),
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
                          Wrap(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                child: ChoiceChip(
                                  label: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Belum',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  selected: _selectedStatus == 'Belum',
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedStatus = 'Belum';
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
                                      'Tertangani',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  selected: _selectedStatus == 'Tertangani',
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedStatus = 'Tertangani';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Penanganan',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Fakta:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 6,
                                      controller: _fakta,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Tolong masukan fakta.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Keterangan:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 6,
                                      controller: _keterangan,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Tolong masukan keterangan.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Catatan:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 6,
                                      controller: _catatan,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Tolong masukan catatan.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Divider(color: Colors.grey[400]),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Dokumentasi Foto:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    _listFileThumb(
                                        image: true, files: _listPenFileFoto),
                                    FlatButton(
                                      onPressed: () {
                                        _addFile(isImage: true);
                                      },
                                      color: Colors.red[50],
                                      child: Container(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(Icons.add),
                                            Text('Tambah foto')
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Dokumentasi Dokumen:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    _listFileThumb(
                                        image: false, files: _listPenFilePDF),
                                    FlatButton(
                                      onPressed: () {
                                        _addFile(isImage: false);
                                      },
                                      color: Colors.red[50],
                                      child: Container(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(Icons.add),
                                            Text('Tambah dokumen')
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'LI & Infosus',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Nomor:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 2,
                                      controller: _nomor,
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Sumber informasi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 2,
                                      controller: _sumberInfo,
                                      validator: (value) {
                                        if (_nomor.text.isNotEmpty &&
                                            value.isEmpty) {
                                          return 'Tolong masukan sumber informasi.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Hubungan dengan sumber:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 2,
                                      controller: _hubunganDenganSumber,
                                      validator: (value) {
                                        if (_nomor.text.isNotEmpty &&
                                            value.isEmpty) {
                                          return 'Tolong masukan hubungan dengan sumber.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Cara mendapatkan informasi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 2,
                                      controller: _caraMendapatkanInfo,
                                      validator: (value) {
                                        if (_nomor.text.isNotEmpty &&
                                            value.isEmpty) {
                                          return 'Tolong masukan cara mendapatkan informasi.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Waktu mendapatkan informasi:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    DateTimeField(
                                      controller: _tanggal,
                                      format: _tanggalFormat,
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                          context: context,
                                          firstDate: DateTime(1900),
                                          initialDate:
                                              currentValue ?? DateTime.now(),
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
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 2,
                                      controller: _nilaiInfo,
                                      validator: (value) {
                                        if (_nomor.text.isNotEmpty &&
                                            value.isEmpty) {
                                          return 'Tolong masukan cara mendapatkan informasi.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Perihal:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 2,
                                      controller: _perihal,
                                      validator: (value) {
                                        if (_nomor.text.isNotEmpty &&
                                            value.isEmpty) {
                                          return 'Tolong masukan cara mendapatkan informasi.';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Langkah Intelijen:',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    TextFormField(
                                      minLines: 1,
                                      maxLines: 2,
                                      controller: _langkahIntelijen,
                                      validator: (value) {
                                        if (_nomor.text.isNotEmpty &&
                                            value.isEmpty) {
                                          return 'Tolong masukan cara mendapatkan informasi.';
                                        }
                                        return null;
                                      },
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
                  ),
                  SizedBox(height: 16.0),
                  FlatButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _connectionProgres = true;
                        });

                        _postAddKonflik();
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 20.0,
                          ),
                          SizedBox(width: 12.0),
                          Text(
                            'Simpan potensi',
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
              key: _formKey,
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

  Widget _trioList() {
    if (SingletonModel.shared.filter != null) {
      FilterModel filter = FilterModel.fromJson(SingletonModel.shared.filter);

      List<ItemFilter> filterWilayah = new List();
      List<ItemFilter> filterBidang = new List();
      List<ItemFilter> filterKategori = new List();

      filter.wilayah.list.forEach((f) {
        filterWilayah.add(ItemFilter(f.namaWilayah, f.id));
      });

      filter.bidang.list.forEach((f) {
        filterBidang.add(ItemFilter(f.namaBidang, f.id));
      });

      filter.kategori.list.forEach((f) {
        filterKategori.add(ItemFilter(f.namaKategori, f.id));
      });
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Wilayah:',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            Container(
              child: DropdownButton<int>(
                value: _selectedWilayah,
                iconSize: 24,
                elevation: 16,
                onChanged: (value) {
                  setState(() {
                    _selectedWilayah = value;
                  });
                },
                hint: Text('Wilayah'),
                isExpanded: true,
                itemHeight: 64.0,
                items: filterWilayah.map<DropdownMenuItem<int>>(
                  (ItemFilter f) {
                    return DropdownMenuItem<int>(
                      value: f.value,
                      child: Text(
                        f.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Bidang:',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            Container(
              child: DropdownButton<int>(
                value: _selectedBidang,
                iconSize: 24,
                elevation: 16,
                onChanged: (value) {
                  setState(() {
                    _selectedBidang = value;

                    // reset kategori
                    _selectedKategori = null;
                  });
                },
                hint: Text('Bidang'),
                isExpanded: true,
                itemHeight: 64.0,
                items: filterBidang.map<DropdownMenuItem<int>>(
                  (ItemFilter f) {
                    return DropdownMenuItem<int>(
                      value: f.value,
                      child: Text(
                        f.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Kategori:',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            Container(
              child: DropdownButton<int>(
                value: _selectedKategori,
                iconSize: 24,
                elevation: 16,
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                  });
                },
                hint: Text('Bidang'),
                isExpanded: true,
                itemHeight: 64.0,
                items: filterKategori.map<DropdownMenuItem<int>>(
                  (ItemFilter f) {
                    return DropdownMenuItem<int>(
                      value: f.value,
                      child: Text(
                        f.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _listFileThumb({bool image = false, List<File> files}) {
    if (image) {
      return Container(
        child: Wrap(
          children: files.map((f) {
            return Container(
              width: 120.0,
              height: 120.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      color: Colors.white,
                    ),
                    child: Image.file(f, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 12.0,
                    right: 0.0,
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(2.0)),
                          color: Colors.red,
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            Text(
                              'Hapus',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          files.remove(f);
                        });
                      },
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Container(
        child: Wrap(
          children: files.map((f) {
            return Container(
              width: 120.0,
              height: 120.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: EdgeInsets.all(2.0),
                    padding: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.picture_as_pdf,
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          p.basename(f.path),
                          style: TextStyle(fontSize: 12.0),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12.0,
                    right: 0.0,
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(2.0)),
                          color: Colors.red,
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            Text(
                              'Hapus',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          files.remove(f);
                        });
                      },
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}

class ItemFilter {
  final String title;
  final int value;

  ItemFilter(this.title, this.value);
}
