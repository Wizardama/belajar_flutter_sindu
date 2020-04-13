import 'dart:convert';

class LaporanModel {
  final int id;
  final String uid;
  final String uidPotensi;
  final int idUser;
  final String nomor;
  final String sumberInformasi;
  final String hubunganDenganSumber;
  final String caraMendapatkanInformasi;
  final String waktuMendapatkanInformasi;
  final String nilaiInformasi;
  final String perihal;
  final String langkahIntelijen;

  LaporanModel(
    this.id,
    this.uid,
    this.uidPotensi,
    this.idUser,
    this.nomor,
    this.sumberInformasi,
    this.hubunganDenganSumber,
    this.caraMendapatkanInformasi,
    this.waktuMendapatkanInformasi,
    this.nilaiInformasi,
    this.perihal,
    this.langkahIntelijen,
  );

  factory LaporanModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return LaporanModel(
      data['laporan']['id'],
      data['laporan']['uid'],
      data['laporan']['uid_potensi'],
      data['laporan']['id_user'],
      data['laporan']['nomor'],
      data['laporan']['sumber_informasi'],
      data['laporan']['hubungan_dgn_sumber'],
      data['laporan']['cara_mendapatkan_informasi'],
      data['laporan']['waktu_mendapatkan_informasi'],
      data['laporan']['nilai_informasi'],
      data['laporan']['perihal'],
      data['laporan']['langkah_intelijen'],
    );
  }
}
