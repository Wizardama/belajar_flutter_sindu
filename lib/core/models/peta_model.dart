import 'dart:convert';

import 'package:latlong/latlong.dart';

class PetaModel {
  final int id;
  final String namaWilayah;
  final LatLng latLng;
  final int total;
  final List<BidangPetaModel> dataBidang;

  PetaModel(
    this.id,
    this.namaWilayah,
    this.latLng,
    this.total,
    this.dataBidang,
  );

  factory PetaModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listBidang = data['data_bidang'] as List;
    List<BidangPetaModel> dataBidang = listBidang
        .map((f) => BidangPetaModel.fromJson(json.encode(f)))
        .toList();

    return PetaModel(
      data['id'],
      data['nama_wilayah'],
      LatLng(double.parse(data['lat']) ?? 0, double.parse(data['lng']) ?? 0),
      data['total'],
      dataBidang,
    );
  }
}

class PetaModels {
  final List<PetaModel> list;

  PetaModels(this.list);

  factory PetaModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['data'] as List;
    List<PetaModel> list =
        listData.map((f) => PetaModel.fromJson(json.encode(f))).toList();

    return PetaModels(list);
  }
}

class BidangPetaModel {
  final int id;
  final String namaBidang;
  final int totalPotensi;
  final int totalMenonjol;

  BidangPetaModel(
    this.id,
    this.namaBidang,
    this.totalPotensi,
    this.totalMenonjol,
  );

  factory BidangPetaModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return BidangPetaModel(
      data['id'],
      data['bidang'],
      data['total_potensi'],
      data['total_menonjol'],
    );
  }
}
