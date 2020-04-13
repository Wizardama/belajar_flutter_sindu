import 'package:digimap_pandonga/core/config/const.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<String> _stepDigitalMapping = [
    'Klik ikon Digital mapping Covid-19 pada menu utama',
    'Akan menampilkan peta persebaran tiap kota',
    'Klik pada marker kota kemudian akan muncul lebih detail ke kecamatan, kemudian kelurahahn',
    'Klik pada marker kelurahan kemudian akan muncul list pasien korona',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Bantuan Aplikasi',
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

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      children: <Widget>[
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
                          'Sebaran Covid-19',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    _stepBuilder(_stepDigitalMapping),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBuilder(List<String> steps) {
    int a = 0;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.map((f) {
          a++;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('$a.'),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text('$f'),
                      flex: 9,
                    )
                  ],
                ),
                SizedBox(height: 16.0),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
