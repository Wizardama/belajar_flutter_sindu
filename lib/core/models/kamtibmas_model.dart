import 'dart:convert';

class KamtibmasModel {
  final int id;
  final int timestamp;
  final int idWilayah;
  final String namaWilayah;
  final String judul;
  final String deskripsi;

  KamtibmasModel(
    this.id,
    this.timestamp,
    this.idWilayah,
    this.namaWilayah,
    this.judul,
    this.deskripsi,
  );

  factory KamtibmasModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return KamtibmasModel(
      data['id'],
      data['timestamp'],
      data['id_wilayah'],
      data['nama_wilayah'],
      data['judul'],
      data['deskripsi'],
    );
  }
}

class KamtibmasModels {
  final List<KamtibmasModel> list;

  KamtibmasModels(this.list);

  factory KamtibmasModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['kamtibmas'] as List;
    List<KamtibmasModel> list =
        listData.map((f) => KamtibmasModel.fromJson(json.encode(f))).toList();

    return KamtibmasModels(list);
  }
}
