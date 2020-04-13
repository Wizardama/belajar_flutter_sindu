import 'package:digimap_pandonga/core/config/const.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<MembersModel> _listKapolda = [
    MembersModel(
      'Irjen Pol Dr. H. Rycko Amelza Dahniel, S.I.K, M.Si',
      'Kapolda Jateng',
    )
  ];
  List<MembersModel> _listOrganizer = [
    MembersModel(
      'Kombes Pol Yuda Gunawan, S.I.K, S.H, M.H',
      'Dirintelkam Polda Jateng',
    ),
  ];
  List<MembersModel> _listLeader = [
    MembersModel(
      'AKBP Priyanto Priyo Hutomo, S.I.K, M.H',
      'Wadirintelkam Polda Jateng',
    ),
    MembersModel(
      'AKBP Danang Kuswoyo, S.I.K',
      'Kasubdit 1 Dit Intelkam Jateng',
    ),
  ];
  List<MembersModel> _listMember = [
    MembersModel(
      'IPDA Septyan Rangga Okky Saputra, S. Tr. K',
      'Panit 3 Subdit 5 Dit Intelkam Polda Jateng',
    ),
    MembersModel(
      'IPDA Tanu Eko Putro, S.Sos',
      'Paur Subbag Doklit Bag Analisis Dit Intelkam Polda Jateng',
    ),
    MembersModel(
      'Briptu Jeffry Henadita, S.H',
      'Ba Dit Intelkam',
    ),
    MembersModel(
      'Briptu Ahmad Rifai',
      'Ba Dit Intelkam',
    ),
    MembersModel(
      'Briptu Dana Laga',
      'Ba Dit Intelkam',
    ),
    MembersModel(
      'Bripda Eka Romadona',
      'Ba Dit Intelkam',
    ),
    MembersModel(
      'Bripda Zafran Luhur Pakerti',
      'Ba Dit Intelkam',
    ),
  ];

  void _dialogVersion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: 'Digital Mapping',
          applicationVersion: '1.0.0',
          applicationLegalese:
              'Sistem Informasi Pemetaan Digital Sebaran Covid-19, Potensi Konflik dan Kejadian Menonjol di Polda Jawa Tengah.',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Tentang Aplikasi',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.import_contacts),
              onPressed: () {
                _dialogVersion();
              })
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/logo_sindu.png',
                      height: 120.0,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Digital Mapping',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Sistem Informasi Pemetaan Digital Sebaran Covid-19, Potensi Konflik dan Kejadian Menonjol di Polda Jawa Tengah.',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              // SizedBox(height: 8.0),
              // Text(
              //   'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries.',
              //   style: TextStyle(
              //     fontSize: 14.0,
              //   ),
              // ),
              // SizedBox(height: 8.0),
              // Text(
              //   'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries.',
              //   style: TextStyle(
              //     fontSize: 14.0,
              //   ),
              // ),
              SizedBox(height: 16.0),
              Text(
                'Sponsor',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              _memberBuilder(_listKapolda),
              SizedBox(height: 8.0),
              Text(
                'Ketua Tim Penyusun',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              _memberBuilder(_listOrganizer),
              SizedBox(height: 8.0),
              Text(
                'Tim Penyusun',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              _memberBuilder(_listLeader),
              SizedBox(height: 8.0),
              Text(
                'Tim Pendukung',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              _memberBuilder(_listMember),
              SizedBox(height: 8.0),
              Text(
                'Tim Pengembang',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0),
              _memberBuilder([
                MembersModel(
                  'Ardiawan Bagus Harisa, S.Kom, M.Sc',
                  'Konsultan IT, Team Leader',
                ),
                MembersModel(
                  'Fatkhurohman',
                  'Mobile programmer & Sistem analis',
                ),
                MembersModel(
                  'Oki Candra Tanjung',
                  'Web programmer',
                ),
                MembersModel(
                  'Rahmad Trinanda Pramudya A.',
                  'Mobile programmer',
                ),
              ])
            ],
          ),
        ),
      ],
    );
  }

  Widget _memberBuilder(List<MembersModel> members) {
    int a = 0;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: members.map((f) {
          a++;
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$a. ${f.nama}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                Row(
                  children: <Widget>[
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        '${f.pangkat}',
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8.0),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MembersModel {
  final String nama;
  final String pangkat;

  MembersModel(this.nama, this.pangkat);
}
