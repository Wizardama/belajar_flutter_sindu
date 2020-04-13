import 'dart:convert';

import 'package:digimap_pandonga/core/models/bidang_model.dart';
import 'package:digimap_pandonga/core/models/kategori_model.dart';
import 'package:digimap_pandonga/core/models/wilayah_model.dart';

class FilterModel {
  WilayahModels wilayah;
  BidangModels bidang;
  KategoriModels kategori;

  FilterModel(
    this.wilayah,
    this.bidang,
    this.kategori,
  );

  factory FilterModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    WilayahModels wilayahData =
        WilayahModels.fromJson(json.encode(data['wilayah']));
    BidangModels bidangData =
        BidangModels.fromJson(json.encode(data['bidang']));
    KategoriModels kategoriData =
        KategoriModels.fromJson(json.encode(data['kategori']));

    return FilterModel(
      wilayahData,
      bidangData,
      kategoriData,
    );
  }
}
