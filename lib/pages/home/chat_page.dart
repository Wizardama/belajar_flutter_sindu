import 'package:digimap_pandonga/pages/home/chat_add_page.dart';
import 'package:digimap_pandonga/pages/home/chat_detail_page.dart';
import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/core/models/user_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';

// Ext
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();

  // Chat
  bool _cacheEmpty = true;
  Future<http.Response> _futureUsers;
  Firestore _firestore = Firestore.instance;

  String _swapUidToName(String uid, UserModels userModels) {
    List<UserModel> newList =
        userModels.list.where((f) => f.uid == uid).toList();

    String name = 'Unknown';

    if (newList.length > 0) {
      name = newList[0].nama;

      return name;
    }

    return name;
  }

  // Enkripsi
  final _key = enc.Key.fromUtf8('my 32 length key................');
  final _iv = enc.IV.fromLength(16);
  enc.Encrypter encrypter;

  void _jumpToPage({Widget page}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _updateFcm() {
    if (SingletonModel.shared.fcm != null) {
      _firestore.collection('user_data').document(_loginModel.uid).setData({
        'fullname': _loginModel.nama,
        'token': SingletonModel.shared.fcm,
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // FCM
    _updateFcm();

    // set users singleton
    if (SingletonModel.shared.users != null) {
      _cacheEmpty = false;
    } else {
      _futureUsers = _api.getUsersData(token: _loginModel.token);
    }

    // Enkripsi
    encrypter = enc.Encrypter(enc.AES(_key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Percakapan',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _futureChat(),
        ),
        FlatButton(
          color: primaryColor,
          onPressed: () {
            _jumpToPage(
              page: ChatAddPage(),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20.0,
                ),
                SizedBox(width: 12.0),
                Text(
                  'Tambah percakapan',
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
    );
  }

  Widget _futureChat() {
    if (_cacheEmpty) {
      return FutureBuilder(
        future: _futureUsers,
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
                  UserModels users = UserModels.fromJson(snapshot.data.body);
                  SingletonModel.shared.users = snapshot.data.body;

                  return _streamChat(users);
                }
              } else if (snapshot.hasError) {
                return Container();
              }
          }

          return Container();
        },
      );
    } else {
      UserModels users = UserModels.fromJson(SingletonModel.shared.users);

      return _streamChat(users);
    }
  }

  Widget _streamChat(UserModels users) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('room_chat')
          .where('member_map.${_loginModel.uid}', isEqualTo: true)
          // .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents.length < 1) {
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close),
                  SizedBox(height: 16.0),
                  Text('Tidak ada pesan.'),
                ],
              ),
            );
          }

          List<DocumentSnapshot> chatrooms = snapshot.data.documents;

          // sort chat
          chatrooms.sort((b, a) => a.data['timestamp']
              .toString()
              .compareTo(b.data['timestamp'].toString()));

          return ListView.builder(
            itemCount: chatrooms.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot chatroom = chatrooms[index];

              if (chatroom.data['type'] == 0) {
                String peer;

                // get uid peer
                chatroom['member_map'].forEach((f, value) {
                  if (f != _loginModel.uid) {
                    peer = f;
                  }
                });

                return StreamBuilder(
                  stream: _firestore
                      .collection('message_data')
                      .orderBy('timestamp', descending: true)
                      .where('room', isEqualTo: chatroom.documentID)
                      .limit(10)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length > 0) {
                        int unread = 0;

                        // get last message
                        snapshot.data.documents.forEach((f) {
                          Map readMap = f['read_map'];
                          if (readMap['${_loginModel.uid}'] == false) {
                            unread++;
                          }
                        });

                        // decrypt message
                        String decrypted = encrypter.decrypt(
                          enc.Encrypted.fromBase64(
                              snapshot.data.documents[0].data['content']),
                          iv: _iv,
                        );

                        // last
                        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                            int.parse(
                                snapshot.data.documents[0].data['timestamp']));

                        return _itemChat(
                          title: '${_swapUidToName(peer, users)}',
                          message: decrypted,
                          roomId: chatroom.documentID,
                          connection: chatroom.data['member_map'],
                          unread: unread,
                          last: '${date.hour}:${date.minute}',
                        );
                      } else {
                        return _itemChat(
                          title: '${_swapUidToName(peer, users)}',
                          message: '...',
                          roomId: chatroom.documentID,
                          connection: chatroom.data['member_map'],
                        );
                      }
                    }
                    return Container();
                  },
                );
              } else if (chatroom.data['type'] == 1) {
                return StreamBuilder(
                  stream: _firestore
                      .collection('message_data')
                      .orderBy('timestamp', descending: true)
                      .where('room', isEqualTo: chatroom.documentID)
                      .limit(10)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length > 0) {
                        int unread = 0;

                        // get last message
                        snapshot.data.documents.forEach((f) {
                          Map readMap = f['read_map'];
                          if (readMap['${_loginModel.uid}'] == false) {
                            unread++;
                          }
                        });

                        // decrypt message
                        String decrypted = encrypter.decrypt(
                          enc.Encrypted.fromBase64(
                              snapshot.data.documents[0].data['content']),
                          iv: _iv,
                        );

                        // last
                        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                            int.parse(
                                snapshot.data.documents[0].data['timestamp']));

                        return _itemChat(
                          title: '${chatroom.data['group_name']}',
                          message: decrypted,
                          roomId: chatroom.documentID,
                          connection: chatroom.data['member_map'],
                          unread: unread,
                          last: '${date.hour}:${date.minute}',
                        );
                      } else {
                        return _itemChat(
                          title: '${chatroom.data['group_name']}',
                          message: '...',
                          roomId: chatroom.documentID,
                          connection: chatroom.data['member_map'],
                        );
                      }
                    }
                    return Container();
                  },
                );
              }

              return Container();
            },
          );
        }

        return Container();
      },
    );
  }

  Widget _itemChat({
    @required String title,
    @required String message,
    @required String roomId,
    @required dynamic connection,
    String last,
    int unread = 0,
  }) {
    return ListTile(
      leading: Icon(
        Icons.account_circle,
        size: 48.0,
      ),
      title: Text('$title'),
      subtitle: Text(
        '$message',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            unread > 0 ? TextStyle(fontWeight: FontWeight.w600) : TextStyle(),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          last != null
              ? Text(
                  '$last',
                  style: const TextStyle(fontSize: 13.0),
                )
              : Text(''),
          unread != 0
              ? Container(
                  width: 20.0,
                  height: 20.0,
                  margin: EdgeInsets.only(top: 4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Text(''),
        ],
      ),
      onTap: () {
        _jumpToPage(
          page: ChatDetailPage(
            peer: title,
            roomId: roomId,
            connection: connection,
          ),
        );
      },
    );
  }
}
