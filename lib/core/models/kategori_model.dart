import 'dart:convert';

class KategoriModel {
  final int id;
  final int idBidang;
  final String namaKategori;

  KategoriModel(
    this.id,
    this.idBidang,
    this.namaKategori,
  );

  factory KategoriModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return KategoriModel(
      data['id'],
      data['id_bidang'],
      data['nama_kategori'],
    );
  }
}

class KategoriModels {
  final List<KategoriModel> list;

  KategoriModels(this.list);

  factory KategoriModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data as List;
    List<KategoriModel> list =
        listData.map((f) => KategoriModel.fromJson(json.encode(f))).toList();

    return KategoriModels(list);
  }
}
