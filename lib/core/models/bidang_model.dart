import 'dart:convert';

class BidangModel {
  final int id;
  final String namaBidang;

  BidangModel(
    this.id,
    this.namaBidang,
  );

  factory BidangModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return BidangModel(
      data['id'],
      data['nama_bidang'],
    );
  }
}

class BidangModels {
  final List<BidangModel> list;

  BidangModels(this.list);

  factory BidangModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data as List;
    List<BidangModel> list =
        listData.map((f) => BidangModel.fromJson(json.encode(f))).toList();

    return BidangModels(list);
  }
}
