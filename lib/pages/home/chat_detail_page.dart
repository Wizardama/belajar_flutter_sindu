import 'dart:io';

import 'package:digimap_pandonga/pages/home/conflict_detail_page.dart';
import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/models/user_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';
import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/pages/home/chat_instruction_page.dart';

// Ext
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart' as p;

class ChatDetailPage extends StatefulWidget {
  final String peer;
  final dynamic connection;
  final String roomId;

  ChatDetailPage(
      {@required this.peer, @required this.connection, @required this.roomId});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
  API _api = API();

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

  // Chat
  bool _cacheEmpty = true;
  Future<http.Response> _futureUsers;
  Firestore _firestore = Firestore.instance;

  void _readMessage() {
    _firestore
        .collection('message_data')
        .where('read_map.${_loginModel.uid}', isEqualTo: false)
        .where('room', isEqualTo: widget.roomId)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      // snapshot.documents.forEach((f) => print('${f.data}'));
      List<String> uids = new List();
      uids.add(_loginModel.uid);

      snapshot.documentChanges.forEach((f) {
        _firestore
            .collection('message_data')
            .document(f.document.documentID)
            .updateData({
          'read_map.${_loginModel.uid}': true,
        });
      });
    });
  }

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

  // Chat Form
  final _formKey = GlobalKey<FormState>();
  TextEditingController _message = TextEditingController();
  bool _expansionWindow = false;
  bool _connectionProgress = false;
  Map _readMap = {};
  Map _receiverMap = {};

  void _uploadFile({bool isImage = false}) async {
    File file;
    if (isImage) {
      file = await FilePicker.getFile(type: FileType.image);
    } else {
      file = await FilePicker.getFile(
          type: FileType.custom, allowedExtensions: ['pdf']);
    }

    if (file != null) {
      setState(() {
        _connectionProgress = true;
        _expansionWindow = false;
      });

      int type;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference;
      if (isImage) {
        type = 2;
        reference = FirebaseStorage.instance.ref().child('images/$fileName');
      } else {
        type = 1;
        reference = FirebaseStorage.instance.ref().child('documents/$fileName');
      }
      StorageUploadTask uploadTask = reference.putFile(file);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

      storageTaskSnapshot.ref.getDownloadURL().then((download) {
        _sendMessage(
            content: download, type: type, filename: p.basename(file.path));
      });
    }
  }

  void _sendMessage(
      {@required String content, int type = 0, String filename}) async {
    _message.clear();

    if (type == 2 || type == 1) {
      _firestore.collection('message_data').add({
        'uid': _loginModel.uid,
        'content': encrypter.encrypt(content, iv: _iv).base64,
        'read_map': _readMap,
        'room': widget.roomId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'file_name': filename,
        'type': type,
      });
    } else if (type == 0) {
      _firestore.collection('message_data').add({
        'uid': _loginModel.uid,
        'content': encrypter.encrypt(content, iv: _iv).base64,
        'read_map': _readMap,
        'room': widget.roomId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
      });
    }

    _firestore.collection('room_chat').document(widget.roomId).updateData({
      'member_map': _receiverMap,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    setState(() {
      _connectionProgress = false;
    });
  }

  // Enkripsi
  final _key = enc.Key.fromUtf8('my 32 length key................');
  final _iv = enc.IV.fromLength(16);
  enc.Encrypter encrypter;

  @override
  void initState() {
    super.initState();

    this.widget.connection.forEach((f, g) {
      _receiverMap[f] = true;

      if (f == _loginModel.uid) {
        _readMap[f] = true;
      } else {
        _readMap[f] = false;
      }
    });

    // set users singleton
    if (SingletonModel.shared.users != null) {
      _cacheEmpty = false;
    } else {
      _futureUsers = _api.getUsersData(token: _loginModel.token);
    }

    // read message
    _readMessage();

    // Enkripsi
    encrypter = enc.Encrypter(enc.AES(_key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.peer}',
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
              Expanded(
                child: _futureChat(),
              ),
              _expansionWindow
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.insert_link),
                                    Text(
                                      'Rencana giat',
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _expansionWindow = false;
                                });
                                _jumpToPage(
                                  page: ChatInstructionPage(
                                      roomId: widget.roomId, readMap: _readMap),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.file_upload),
                                    Text(
                                      'Upload file',
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _expansionWindow = false;
                                });
                                _uploadFile();
                              },
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.photo),
                                    Text(
                                      'Upload gambar',
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _expansionWindow = false;
                                });
                                _uploadFile(isImage: true);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _expansionWindow = !_expansionWindow;
                            });
                          },
                        ),
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _message,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                alignLabelWithHint: false,
                                hintText: 'Tulis pesan anda',
                                labelText: 'Pesan',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            // FocusScope.of(context).requestFocus(FocusNode());
                            if (_formKey.currentState.validate()) {
                              _sendMessage(content: _message.text);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        _connectionProgress
            ? Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
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
                      'Sedang mengupload file.',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              )
            : Container()
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
          .collection('message_data')
          .where('room', isEqualTo: widget.roomId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> messages = snapshot.data.documents;

          return ListView.builder(
            itemCount: messages.length,
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            itemBuilder: (BuildContext context, int index) {
              // return Text('${messages[index].data['content']}');
              return _itemBubble(data: messages[index].data, users: users);
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _itemBubble({
    @required Map<String, dynamic> data,
    @required UserModels users,
  }) {
    bool isMe = data['uid'] == _loginModel.uid;
    String decrypted = encrypter.decrypt(
      enc.Encrypted.fromBase64(data['content']),
      iv: _iv,
    );
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(data['timestamp']),
    );

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: isMe
          ? EdgeInsets.only(
              left: 16.0,
              right: 6.0,
              top: 6.0,
              bottom: 6.0,
            )
          : EdgeInsets.only(
              left: 6.0,
              right: 16.0,
              top: 6.0,
              bottom: 6.0,
            ),
      padding:
          isMe ? EdgeInsets.only(left: 40.0) : EdgeInsets.only(right: 40.0),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.grey[200] : Colors.red,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
            ),
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${_swapUidToName(data['uid'], users)}',
                        style: TextStyle(
                          color: isMe ? Colors.black87 : Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        '${date.hour}:${date.minute}',
                        style: TextStyle(
                          color: isMe ? Colors.grey : Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  _bubbleContent(
                    content: decrypted,
                    isMe: isMe,
                    type: data['type'],
                    data: data,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubbleContent(
      {int type = 0,
      @required String content,
      @required bool isMe,
      @required dynamic data}) {
    if (type == 1) {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Text(
                    data['file_name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.0),
              Icon(Icons.file_download),
            ],
          ),
        ),
        onTap: () {
          _launchURL(content);
        },
      );
    } else if (type == 2) {
      return Container(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          child: CachedNetworkImage(
            imageUrl: content,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (type == 3) {
      Map konflikMap = data['konflik_map'];

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${konflikMap['judul']}',
              maxLines: 3,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Divider(),
            SizedBox(height: 8.0),
            Text(
              '${konflikMap['nama_wilayah']}',
              maxLines: 2,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                color: Colors.red,
                onPressed: () {
                  _jumpToPage(
                    page: ConlfictDetailPage(
                      refresh: null,
                      uid: '${konflikMap['uid']}',
                      noAction: true,
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Detail Instruksi',
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
      );
    } else {
      return SelectableText(
        '$content',
        textAlign: isMe ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isMe ? Colors.black87 : Colors.white,
          fontSize: 14.0,
        ),
      );
    }
  }
}
