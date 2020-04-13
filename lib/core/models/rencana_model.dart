import 'dart:convert';

class RencanaDetailModel extends RencanaModel {
  // fakta, keterangan, catatan

  final String fakta;
  final String keterangan;
  final String catatan;

  RencanaDetailModel(
    String uid,
    String uidPotensi,
    String tglRG,
    String judul,
    int status,
    this.fakta,
    this.keterangan,
    this.catatan,
  ) : super(uid, uidPotensi, tglRG, judul, status);

  factory RencanaDetailModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return RencanaDetailModel(
      data['ren_giat']['uid'],
      data['ren_giat']['uid_potensi'],
      data['ren_giat']['tgl_ren_giat'],
      data['ren_giat']['judul'],
      0,
      data['ren_giat']['fakta'],
      data['ren_giat']['keterangan'],
      data['ren_giat']['catatan'],
    );
  }
}

class RencanaModel {
  final String uid;
  final String uidPotensi;
  final String tglRG;
  final String judul;
  final int status;

  RencanaModel(
    this.uid,
    this.uidPotensi,
    this.tglRG,
    this.judul,
    this.status,
  );

  factory RencanaModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return RencanaModel(
      data['uid'],
      data['uid_potensi'],
      data['tgl_ren_giat'],
      data['judul'],
      data['status'],
    );
  }
}

class WilayahRGModel {
  final int id;
  final String namaWilayah;
  final int total;
  final List<RencanaModel> rencana;

  WilayahRGModel(this.id, this.namaWilayah, this.total, this.rencana);

  factory WilayahRGModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['ren_giat'] as List;
    List<RencanaModel> list =
        listData.map((f) => RencanaModel.fromJson(json.encode(f))).toList();

    return WilayahRGModel(
      data['id'],
      data['nama_wilayah'],
      data['total'],
      list,
    );
  }
}

class WilayahRGModels {
  final List<WilayahRGModel> list;

  WilayahRGModels(this.list);

  factory WilayahRGModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['wilayah'] as List;
    List<WilayahRGModel> list =
        listData.map((f) => WilayahRGModel.fromJson(json.encode(f))).toList();

    return WilayahRGModels(list);
  }
}
