import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/konflik_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:encrypt/encrypt.dart' as enc;

import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class ChatInstructionPage extends StatefulWidget {
  final String roomId;
  final Map readMap;

  ChatInstructionPage({@required this.roomId, @required this.readMap});

  @override
  _ChatInstructionPageState createState() => _ChatInstructionPageState();
}

class _ChatInstructionPageState extends State<ChatInstructionPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();

  Future<http.Response> _futureInstruksi;

  Firestore _firestore = Firestore.instance;

  // Enkripsi
  final _key = enc.Key.fromUtf8('my 32 length key................');
  final _iv = enc.IV.fromLength(16);
  enc.Encrypter encrypter;

  void _sendInstruction({
    @required String content,
    @required String potensiUid,
    @required Map konflikMap,
  }) {
    _firestore.collection('message_data').add({
      'uid': _loginModel.uid,
      'content': encrypter.encrypt(content, iv: _iv).base64,
      'read_map': widget.readMap,
      'room': widget.roomId,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 3,
      'konflik_map': konflikMap,
    });

    Toast.show("Instruksi berhasil dikirim", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    _futureInstruksi = _api.getInstruksiData(token: _loginModel.token);

    // Enkripsi
    encrypter = enc.Encrypter(enc.AES(_key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instruksi Rencana Giat',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // return ListView(
    //   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    //   children: <Widget>[_itemInstruction()],
    // );

    return FutureBuilder(
      future: _futureInstruksi,
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
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
                KonflikInstruksiModels konfliks =
                    KonflikInstruksiModels.fromJson(snapshot.data.body);

                if (konfliks.list.length > 0) {
                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: konfliks.list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _itemInstruction(konfliks.list[index]);
                    },
                  );
                } else {
                  return Container();
                }
              }
            }
        }
        return Container();
      },
    );
  }

  Widget _itemInstruction(KonflikModel konflik) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: <Widget>[
            Text(
              '${konflik.judul}',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Divider(),
            SizedBox(height: 8.0),
            Text(
              '${konflik.namaWilayah}',
              maxLines: 2,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'BIDANG',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('${konflik.namaBidang}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'KATEGORI',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('${konflik.namaKategori}'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Container(
              child: FlatButton(
                color: Colors.red,
                onPressed: () {
                  _sendInstruction(
                    content: konflik.judul,
                    potensiUid: konflik.uid,
                    konflikMap: {
                      'judul': konflik.judul,
                      'uid': konflik.uid,
                      'nama_wilayah': konflik.namaWilayah,
                      'nama_bidang': konflik.namaBidang,
                      'nama_kategori': konflik.namaKategori,
                    },
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Kirim Instruksi',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 16.0),
                    Icon(Icons.arrow_forward, color: Colors.white)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
