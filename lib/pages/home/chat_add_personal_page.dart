import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digimap_pandonga/core/models/user_model.dart';
import 'package:digimap_pandonga/pages/home/chat_detail_page.dart';
import 'package:flutter/material.dart';

import '../../core/datasource/API.dart';
import '../../core/models/login_model.dart';
import '../../core/models/singleton_model.dart';

// const String uid = 'q235MnDeD';

class ChatAddPersonalPage extends StatefulWidget {
  @override
  _ChatAddPersonalPageState createState() => _ChatAddPersonalPageState();
}

class _ChatAddPersonalPageState extends State<ChatAddPersonalPage> {
  final databaseReference = Firestore.instance;

  bool _process = false;
  bool _hasError = false;

  API _api = API();
  LoginModel _loginModel;
  UserModels _userModels;

  void _checkRoom(String uidPeer, String peer) {
    setState(() {
      _process = true;
    });

    Map memberMap = {
      '${_loginModel.uid}': true,
      '$uidPeer': true,
    };
    databaseReference
        .collection('room_chat')
        .where('type', isEqualTo: 0)
        .where('member_map.${_loginModel.uid}', isEqualTo: true)
        .where('member_map.$uidPeer', isEqualTo: true)
        .getDocuments()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.documents.length > 0) {
        String room = snapshot.documents.single.documentID;
        databaseReference.collection('room_chat').document(room).updateData({
          'member_map': memberMap,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        });

        // goto detail chat page
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              roomId: room,
              connection: snapshot.documents.single.data['member_map'],
              peer: peer,
            ),
          ),
        );
      } else {
        Map memberMap = {
          '${_loginModel.uid}': true,
          '$uidPeer': true,
        };
        databaseReference
            .collection('room_chat')
            .where('type', isEqualTo: 0)
            .where('member_map.${_loginModel.uid}', isEqualTo: false)
            .where('member_map.$uidPeer', isEqualTo: true)
            .getDocuments()
            .then((QuerySnapshot snapshot) async {
          if (snapshot.documents.length > 0) {
            String room = snapshot.documents.single.documentID;
            databaseReference
                .collection('room_chat')
                .document(room)
                .updateData({
              'member_map': memberMap,
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            });

            // goto detail chat page
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailPage(
                  roomId: room,
                  connection: snapshot.documents.single.data['member_map'],
                  peer: peer,
                ),
              ),
            );
          } else {
            Map memberMap = {
              '${_loginModel.uid}': true,
              '$uidPeer': true,
            };

            databaseReference
                .collection('room_chat')
                .where('type', isEqualTo: 0)
                .where('member_map.${_loginModel.uid}', isEqualTo: true)
                .where('member_map.$uidPeer', isEqualTo: false)
                .getDocuments()
                .then((QuerySnapshot snapshot) async {
              if (snapshot.documents.length > 0) {
                String room = snapshot.documents.single.documentID;

                databaseReference
                    .collection('room_chat')
                    .document(room)
                    .updateData({
                  'member_map': memberMap,
                  'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                });

                // goto detail chat page
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatDetailPage(
                      roomId: room,
                      connection: snapshot.documents.single.data['member_map'],
                      peer: peer,
                    ),
                  ),
                );
              } else {
                Map memberMap = {
                  '${_loginModel.uid}': true,
                  '$uidPeer': true,
                };

                DocumentReference ref =
                    await databaseReference.collection('room_chat').add({
                  'member_map': memberMap,
                  'type': 0,
                  'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                });

                // goto detail chat page
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatDetailPage(
                      roomId: ref.documentID,
                      connection: memberMap,
                      peer: peer,
                    ),
                  ),
                );
              }
            });
          }
        });
      }
    });
  }

  void _loadUsers() async {
    final response = await _api.getUsersData(token: _loginModel.token);

    if (SingletonModel.shared.users != null) {
      setState(() {
        _userModels = UserModels.fromJson(response.body);
        _process = false;
      });
    } else {
      if (response.statusCode == 200) {
        setState(() {
          SingletonModel.shared.users = response.body;
          _userModels = UserModels.fromJson(response.body);
          _process = false;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _process = true;
    _api.getUsersData(token: null);
    _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Percakapan personal',
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
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Text(
                  'Pilih penerima:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: _userModels == null
                      ? <Widget>[]
                      : _userModels.list.map((f) {
                          if (f.uid != _loginModel.uid) {
                            return Container(
                              child: ListTile(
                                title: Text('${f.nama}'),
                                subtitle: Text('${f.pangkat}'),
                                onTap: () {
                                  _checkRoom('${f.uid}', '${f.nama}');
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList(),
                ),
              )
            ],
          ),
        ),
        _process ? _loadingUpload() : Container(),
      ],
    );
  }

  Widget _loadingUpload() {
    // loading page
    return Container(
      width: double.infinity,
      color: Colors.white.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16.0),
          Text('Mengambil data dari server.')
        ],
      ),
    );
  }
}
