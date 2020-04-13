import 'dart:convert';

class DokumenKonflikModel {
  final String filename;
  final String location;
  final String type;

  DokumenKonflikModel(this.filename, this.location, this.type);

  factory DokumenKonflikModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return DokumenKonflikModel(
        data['filename'], data['location'], data['type']);
  }
}

class PenangananKonflikModel {
  final int id;
  final String fakta;
  final String keterangan;

  PenangananKonflikModel(this.id, this.fakta, this.keterangan);

  factory PenangananKonflikModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return PenangananKonflikModel(
      data['id'],
      data['fakta'],
      data['keterangan'],
    );
  }
}

class LaporanKonflikModel {
  final String nomor;
  final String sumberInformasi;
  final String hubunganDenganSumber;
  final String caraMendapatkanInformasi;
  final String waktuMendapatkanInformasi;
  final String nilaiInformasi;
  final String perihal;
  final String langkahIntelijen;

  LaporanKonflikModel(
    this.nomor,
    this.sumberInformasi,
    this.hubunganDenganSumber,
    this.caraMendapatkanInformasi,
    this.waktuMendapatkanInformasi,
    this.nilaiInformasi,
    this.perihal,
    this.langkahIntelijen,
  );

  factory LaporanKonflikModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return LaporanKonflikModel(
      data['nomor'],
      data['sumber_informasi'],
      data['hubungan_dgn_sumber'],
      data['cara_mendapatkan_informasi'],
      data['waktu_mendapatkan_informasi'],
      data['nilai_informasi'],
      data['perihal'],
      data['langkah_intelijen'],
    );
  }
}

class KonflikDetailModel {
  final int id;
  final String uid;
  final String judul;
  final int jenis;
  final String namaWilayah;
  final int idBidang;
  final String bidang;
  final String kategori;
  final String waktuPotensiKonflik;
  final String uraianPotensiKonflik;
  final String analisa;
  final String prediksi;
  final String rekomendasi;
  final int statusPenanggulangan;

  // Dokumen potensi
  final List<DokumenKonflikModel> listDokPotensi;

  // PenangananKonflikModel
  final PenangananKonflikModel penanganan;
  final List<DokumenKonflikModel> listDokPenanganan;

  // LaporanKonflikModel
  final LaporanKonflikModel laporan;

  KonflikDetailModel(
      this.id,
      this.uid,
      this.judul,
      this.jenis,
      this.namaWilayah,
      this.idBidang,
      this.bidang,
      this.kategori,
      this.waktuPotensiKonflik,
      this.uraianPotensiKonflik,
      this.analisa,
      this.prediksi,
      this.rekomendasi,
      this.statusPenanggulangan,
      this.listDokPotensi,
      this.penanganan,
      this.listDokPenanganan,
      this.laporan);

  factory KonflikDetailModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    final listDokPotensi = data['dok_potensi'] as List;
    List<DokumenKonflikModel> listDokPotensiData = listDokPotensi
        .map((f) => DokumenKonflikModel.fromJson(json.encode(f)))
        .toList();

    final dataPenanganan = data['penanganan']['id'] != null
        ? PenangananKonflikModel.fromJson(json.encode(data['penanganan']))
        : null;

    final listDokPena = data['dok_penanganan'] as List;
    List<DokumenKonflikModel> listDokPenaData = listDokPena
        .map((f) => DokumenKonflikModel.fromJson(json.encode(f)))
        .toList();

    final dataLaporan = data['laporan']['perihal'] != null &&
            data['laporan']['langkah_intelijen'] != null
        ? LaporanKonflikModel.fromJson(json.encode(data['laporan']))
        : null;

    return KonflikDetailModel(
      data['potensi']['id'],
      data['potensi']['uid'],
      data['potensi']['judul'],
      data['potensi']['jenis'],
      data['potensi']['nama_wilayah'],
      data['potensi']['id_bidang'],
      data['potensi']['bidang'],
      data['potensi']['kategori'],
      data['potensi']['waktu_potensi_konflik'],
      data['potensi']['uraian_potensi_konflik'],
      data['potensi']['analisa'],
      data['potensi']['prediksi'],
      data['potensi']['rekomendasi'],
      data['potensi']['status_penanggulangan'],
      listDokPotensiData,
      dataPenanganan,
      listDokPenaData,
      dataLaporan,
    );
  }
}

///////////////////////// ini diatas ada detail

class KonflikModel {
  final int id;
  final String uid;
  final String location;
  final String noRegister;
  final String judul;
  final String jenis;
  final int idWilayah;
  final String namaWilayah;
  final int idBidang;
  final String namaBidang;
  final String namaKategori;
  final String statusPenanganan;

  KonflikModel(
    this.id,
    this.uid,
    this.location,
    this.noRegister,
    this.judul,
    this.jenis,
    this.idWilayah,
    this.namaWilayah,
    this.idBidang,
    this.namaBidang,
    this.namaKategori,
    this.statusPenanganan,
  );

  factory KonflikModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return KonflikModel(
      data['id'],
      data['uid'],
      data['location'],
      data['no_register'],
      data['judul'],
      data['jenis'],
      data['id_wilayah'],
      data['nama_wilayah'],
      data['id_bidang'],
      data['bidang'],
      data['kategori'],
      data['status_penanganan'],
    );
  }
}

class KonflikModels {
  final List<KonflikModel> list;
  final int currentPage;
  final int lastPage;

  KonflikModels(
    this.list,
    this.currentPage,
    this.lastPage,
  );

  factory KonflikModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['potensi']['data'] as List;
    List<KonflikModel> list =
        listData.map((f) => KonflikModel.fromJson(json.encode(f))).toList();

    return KonflikModels(
      list,
      data['potensi']['current_page'],
      data['potensi']['last_page'],
    );
  }
}

class KonflikInstruksiModels {
  final List<KonflikModel> list;

  KonflikInstruksiModels(
    this.list,
  );

  factory KonflikInstruksiModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['potensi'] as List;
    List<KonflikModel> list =
        listData.map((f) => KonflikModel.fromJson(json.encode(f))).toList();

    return KonflikInstruksiModels(
      list,
    );
  }
}
