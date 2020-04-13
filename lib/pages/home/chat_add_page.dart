import 'package:digimap_pandonga/pages/home/chat_add_group_page.dart';
import 'package:digimap_pandonga/pages/home/chat_add_personal_page.dart';
import 'package:flutter/material.dart';

const String uid = 'q235MnDeD';

class ChatAddPage extends StatefulWidget {
  @override
  _ChatAddPageState createState() => _ChatAddPageState();
}

class _ChatAddPageState extends State<ChatAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah percakapan',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final gridCount = MediaQuery.of(context).size.width ~/ 160.0;
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            24.0,
            16.0,
            24.0,
            16.0,
          ),
          child: GridView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            children: <Widget>[
              _itemMenu(
                title: 'Percakapan personal',
                icon: Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.red,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatAddPersonalPage()),
                  );
                },
              ),
              _itemMenu(
                title: 'Percakapan group',
                icon: Icon(
                  Icons.group,
                  size: 48,
                  color: Colors.red,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatAddGroupPage()),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _itemMenu({
    @required String title,
    @required Icon icon,
    Function onTap,
  }) {
    return GestureDetector(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              icon,
              SizedBox(height: 8.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
