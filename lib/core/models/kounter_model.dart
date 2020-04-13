import 'dart:convert';

class KounterModel {
  final int id;
  final String nama;
  final int totalPotensi;
  final int totalMenonjol;

  KounterModel(this.id, this.nama, this.totalPotensi, this.totalMenonjol);

  factory KounterModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return KounterModel(data['id_kategori'], data['nama_kategori'], data['total_potensi'], data['total_menonjol']);
  }
}

class KounterModels {
  final List<KounterModel> list;

  KounterModels(this.list);

  factory KounterModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['data'] as List;
    List<KounterModel> list =
        listData.map((f) => KounterModel.fromJson(json.encode(f))).toList();

    return KounterModels(list);
  }
}
