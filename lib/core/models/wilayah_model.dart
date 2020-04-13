import 'dart:convert';

class WilayahModel {
  final int id;
  final String namaWilayah;

  WilayahModel(
    this.id,
    this.namaWilayah,
  );

  factory WilayahModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return WilayahModel(
      data['id'],
      data['nama_wilayah'],
    );
  }
}

class WilayahModels {
  final List<WilayahModel> list;

  WilayahModels(this.list);

  factory WilayahModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data as List;
    List<WilayahModel> list =
        listData.map((f) => WilayahModel.fromJson(json.encode(f))).toList();

    return WilayahModels(list);
  }
}
