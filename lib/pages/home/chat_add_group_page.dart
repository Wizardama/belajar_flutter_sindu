import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digimap_pandonga/core/models/user_model.dart';
import 'package:digimap_pandonga/pages/home/chat_detail_page.dart';
import 'package:flutter/material.dart';

import '../../core/datasource/API.dart';
import '../../core/models/login_model.dart';
import '../../core/models/singleton_model.dart';

class ChatAddGroupPage extends StatefulWidget {
  @override
  _ChatAddGroupPageState createState() => _ChatAddGroupPageState();
}

class _ChatAddGroupPageState extends State<ChatAddGroupPage> {
  final databaseReference = Firestore.instance;

  bool _processLoad = false;
  bool _process = false;
  bool _hasError = false;

  API _api = API();
  LoginModel _loginModel;
  UserModels _userModels;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _group = TextEditingController();

  // tampung user group
  List<Map<String, bool>> _memberList = new List();
  int i = 0;

  void _createGroup({
    @required Map memberMap,
    @required members,
  }) async {
    try {
      setState(() {
        _process = true;
      });

      DocumentReference ref =
          await databaseReference.collection('room_chat').add({
        'group_name': _group.text,
        'member_map': memberMap,
        'type': 1,
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
            peer: _group.text,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _process = false;
      });
      print(e.toString());
    }
  }

  void _loadUsers() async {
    final response = await _api.getUsersData(token: _loginModel.token);

    if (SingletonModel.shared.users != null) {
      setState(() {
        _userModels = UserModels.fromJson(response.body);
        _processLoad = false;

        if (_userModels.list.length > 0) {
          _userModels.list.forEach((f) {
            _memberList.add({'${f.uid}': false});
          });
        }
      });
    } else {
      if (response.statusCode == 200) {
        setState(() {
          SingletonModel.shared.users = response.body;
          _userModels = UserModels.fromJson(response.body);
          _processLoad = false;

          if (_userModels.list.length > 0) {
            _userModels.list.forEach((f) {
              _memberList.add({'${f.uid}': false});
            });
          }
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
    _processLoad = true;
    _loginModel = LoginModel.fromJson(SingletonModel.shared.login);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Percakapan group',
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
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                color: Colors.white,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _group,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nama group',
                      hintText: 'Tulis nama group',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Tolong masukan nama group.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Pilih anggota group',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Expanded(
                child: _processLoad
                    ? _loadingContent()
                    : ListView(
                        children: _userModels.list.length > 0
                            ? _userModels.list.map((f) {
                                i++;
                                if (f.uid != _loginModel.uid) {
                                  return CheckboxListTile(
                                    value: _memberList.singleWhere((g) =>
                                        g.containsKey('${f.uid}'))['${f.uid}'],
                                    onChanged: (bool value) {
                                      setState(() {
                                        _memberList.singleWhere((g) =>
                                                g.containsKey('${f.uid}'))[
                                            '${f.uid}'] = value;
                                      });
                                    },
                                    title: Text('${f.nama}'),
                                    subtitle: Text('${f.pangkat}'),
                                  );
                                } else {
                                  i--;
                                  return Container();
                                }
                              }).toList()
                            : Container(),
                      ),
              ),
              Container(
                child: FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      List<Map<String, bool>> membersList = _memberList
                          .where((f) => f.containsValue(true))
                          .toList();

                      if (membersList.length > 0) {
                        membersList.add({'${_loginModel.uid}': true});

                        List<String> members = membersList.map((f) {
                          return f.keys
                              .toString()
                              .replaceAll(RegExp(r'[()]'), '');
                        }).toList();

                        Map membersMap = Map.fromIterable(members,
                            key: (e) => e, value: (e) => true);

                        // print({
                        //   'group_name': _group.text,
                        //   'member_map': membersMap,
                        //   'members': members,
                        //   'type': 1,
                        // });

                        _createGroup(
                          members: members,
                          memberMap: membersMap,
                        );
                      }
                    }
                  },
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        size: 16.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        'Tambah group',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _process ? _loadingUpload() : Container(),
      ],
    );
  }

  Widget _loadingContent() {
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
          Text('Mengirim data ke server.')
        ],
      ),
    );
  }
}
