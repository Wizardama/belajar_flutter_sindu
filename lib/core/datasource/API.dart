import 'dart:async';
import 'dart:io';

// Ext
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

class API {
  final String baseUrl = 'https://apps.cosmopol.pandonga.com/api/';

  Future<http.Response> postAuth({
    @required String username,
    @required String password,
  }) async {
    try {
      return await http.post(
        baseUrl + 'apps/login',
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'username': username,
          'password': password,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada klien.');
    }
  }

  Future<http.Response> getFilterData({
    @required String token,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/potensi-konflik/get/dropdown',
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Waktu tunggu habis.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet anda.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada perangkat.');
    }
  }

  Future<http.Response> getKounterData({
    @required String token,
    @required int idWilayah,
    @required int idBidang,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/potensi-konflik/peta/wilayah/$idWilayah/$idBidang',
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Waktu tunggu habis.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet anda.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada perangkat.');
    }
  }

  Future<http.Response> getMapData({
    @required String token,
    bool terkini,
  }) async {
    String additionalUrl = '';
    if (terkini) {
      if (additionalUrl != '') {
        additionalUrl += '&terkini=1';
      } else {
        additionalUrl += '?terkini=1';
      }
    }
    try {
      return await http.get(
        baseUrl + 'apps/potensi-konflik/peta/wilayah' + additionalUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Waktu tunggu habis.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet anda.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada perangkat.');
    }
  }

  Future<http.Response> getKonflikData({
    @required String token,
    int wilayah,
    int bidang,
    int kategori,
    int jenis,
    bool terkini = false,
    int page = 1,
  }) async {
    String additionalUrl = '';

    if (wilayah != null && wilayah != 0) {
      additionalUrl = '?id_wilayah=$wilayah';
    }

    if (bidang != null && bidang != 0) {
      if (additionalUrl != '') {
        additionalUrl += '&id_bidang=$bidang';
      } else {
        additionalUrl += '?id_bidang=$bidang';
      }
    }

    if (kategori != null && kategori != 0) {
      if (additionalUrl != '') {
        additionalUrl += '&id_kategori=$kategori';
      } else {
        additionalUrl += '?id_kategori=$kategori';
      }
    }

    if (jenis != null && jenis != 2) {
      if (additionalUrl != '') {
        additionalUrl += '&jenis=$jenis';
      } else {
        additionalUrl += '?jenis=$jenis';
      }
    }

    if (page != 1) {
      if (additionalUrl != '') {
        additionalUrl += '&page=$page';
      } else {
        additionalUrl += '?page=$page';
      }
    }

    if (terkini) {
      if (additionalUrl != '') {
        additionalUrl += '&terkini=1';
      } else {
        additionalUrl += '?terkini=1';
      }
    }

    print(baseUrl + 'apps/potensi-konflik/data' + additionalUrl);

    try {
      return await http.get(
        baseUrl + 'apps/potensi-konflik/data' + additionalUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Waktu tunggu habis.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet anda.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada perangkat.');
    }
  }

  Future<http.Response> getKonflikDetail({
    @required String token,
    @required String uid,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/potensi-konflik/detil/' + uid,
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Waktu tunggu habis.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet anda.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada perangkat.');
    }
  }

  Future<http.Response> getKonflikDelete({
    @required String token,
    @required String uid,
  }) async {
    try {
      return await http.delete(
        baseUrl + 'apps/potensi-konflik/hapus/' + uid,
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Waktu tunggu habis.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet anda.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada perangkat.');
    }
  }

  Future<http.Response> postKonflikAdd({
    @required String token,
    @required String judul,
    @required int jenis,
    @required int idWilayah,
    @required int idBidang,
    @required int idKategori,
    @required String waktuPotensiKonflik,
    @required String uraian,
    @required String prediksi,
    @required String rekomendasi,
    @required String analisa,
    @required int status,
    @required List<File> potensiFoto,
    @required List<File> potensiDoc,

    // Part 2 - Penangangan
    @required String fakta,
    @required String keterangan,
    @required String catatan,
    @required List<File> penangananFoto,
    @required List<File> penangananDoc,

    // Part 3 - LI & Infosus
    @required String nomor,
    @required String sumberInformasi,
    @required String hubunganDgnSumber,
    @required String caraMendapatkanInfo,
    @required String waktuMendapatkanInfo,
    @required String nilaiInformasi,
    @required String perihal,
    @required String langkahIntelijen,
  }) async {
    try {
      Uri uri = Uri.parse(baseUrl + 'apps/potensi-konflik/tambah');
      http.MultipartRequest request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';

      request.fields['judul'] = judul;
      request.fields['jenis'] = jenis.toString();
      request.fields['id_wilayah'] = idWilayah.toString();
      request.fields['id_bidang'] = idBidang.toString();
      request.fields['id_kategori'] = idKategori.toString();
      request.fields['waktu_potensi_konflik'] = waktuPotensiKonflik;
      request.fields['uraian'] = uraian;
      request.fields['prediksi'] = prediksi;
      request.fields['rekomendasi'] = rekomendasi;
      request.fields['analisa'] = analisa;
      request.fields['status'] = status.toString();

      int a = 0;
      for (File file in potensiFoto) {
        request.files.add(
          http.MultipartFile(
            'images[$a]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        a++;
      }

      int b = 0;
      for (File file in potensiDoc) {
        request.files.add(
          http.MultipartFile(
            'documents[$b]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        b++;
      }

      // Part 3 - Penanganan
      request.fields['fakta'] = fakta;
      request.fields['keterangan'] = keterangan;
      request.fields['catatan'] = catatan;

      int c = 0;
      for (File file in penangananFoto) {
        request.files.add(
          http.MultipartFile(
            'png_images[$c]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        c++;
      }

      int d = 0;
      for (File file in penangananDoc) {
        request.files.add(
          http.MultipartFile(
            'png_documents[$d]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        d++;
      }

      // Part 3 - LI & Infosus
      request.fields['nomor'] = nomor ?? "";
      request.fields['sumber_informasi'] = sumberInformasi ?? "";
      request.fields['hubungan_dgn_sumber'] = hubunganDgnSumber ?? "";
      request.fields['cara_mendapatkan_informasi'] = caraMendapatkanInfo ?? "";
      request.fields['waktu_mendapatkan_informasi'] =
          waktuMendapatkanInfo ?? "";
      request.fields['nilai_informasi'] = nilaiInformasi ?? "";
      request.fields['perihal'] = perihal ?? "";
      request.fields['langkah_intelijen'] = langkahIntelijen ?? "";

      http.StreamedResponse response = await request.send();
      return await http.Response.fromStream(response);
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> postKonflikEdit({
    @required String token,
    @required String uid,
    @required String judul,
    @required int jenis,
    @required int idWilayah,
    @required int idBidang,
    @required int idKategori,
    @required String waktuPotensiKonflik,
    @required String uraian,
    @required String prediksi,
    @required String rekomendasi,
    @required String analisa,
    @required int status,
    @required List<File> potensiFoto,
    @required List<File> potensiDoc,

    // Part 2 - Penangangan
    @required String fakta,
    @required String keterangan,
    @required String catatan,
    @required List<File> penangananFoto,
    @required List<File> penangananDoc,

    // Part 3 - LI & Infosus
    @required String nomor,
    @required String sumberInformasi,
    @required String hubunganDgnSumber,
    @required String caraMendapatkanInfo,
    @required String waktuMendapatkanInfo,
    @required String nilaiInformasi,
    @required String perihal,
    @required String langkahIntelijen,
  }) async {
    try {
      Uri uri = Uri.parse(baseUrl + 'apps/potensi-konflik/ubah/' + uid);
      http.MultipartRequest request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';

      request.fields['judul'] = judul;
      request.fields['jenis'] = jenis.toString();
      request.fields['id_wilayah'] = idWilayah.toString();
      request.fields['id_bidang'] = idBidang.toString();
      request.fields['id_kategori'] = idKategori.toString();
      request.fields['waktu_potensi_konflik'] = waktuPotensiKonflik;
      request.fields['uraian'] = uraian;
      request.fields['prediksi'] = prediksi;
      request.fields['rekomendasi'] = rekomendasi;
      request.fields['analisa'] = analisa;
      request.fields['status'] = status.toString();

      int a = 0;
      for (File file in potensiFoto) {
        request.files.add(
          http.MultipartFile(
            'images[$a]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        a++;
      }

      int b = 0;
      for (File file in potensiDoc) {
        request.files.add(
          http.MultipartFile(
            'documents[$b]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        b++;
      }

      // Part 2 - Penanganan
      request.fields['fakta'] = fakta;
      request.fields['keterangan'] = keterangan;
      request.fields['catatan'] = catatan;

      int c = 0;
      for (File file in penangananFoto) {
        request.files.add(
          http.MultipartFile(
            'png_images[$c]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        c++;
      }

      int d = 0;
      for (File file in penangananDoc) {
        request.files.add(
          http.MultipartFile(
            'png_documents[$d]',
            http.ByteStream(Stream.castFrom(file.openRead())),
            await file.length(),
            filename: file.path,
          ),
        );
        d++;
      }

      // Part 3 - LI & Infosus
      request.fields['nomor'] = nomor ?? "";
      request.fields['sumber_informasi'] = sumberInformasi ?? "";
      request.fields['hubungan_dgn_sumber'] = hubunganDgnSumber ?? "";
      request.fields['cara_mendapatkan_informasi'] = caraMendapatkanInfo ?? "";
      request.fields['waktu_mendapatkan_informasi'] =
          waktuMendapatkanInfo ?? "";
      request.fields['nilai_informasi'] = nilaiInformasi ?? "";
      request.fields['perihal'] = perihal ?? "";
      request.fields['langkah_intelijen'] = langkahIntelijen ?? "";

      http.StreamedResponse response = await request.send();
      return await http.Response.fromStream(response);
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> getInstruksiData({
    @required String token,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/potensi-konflik/instruksi/data',
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('Waktu tunggu habis.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('Periksa koneksi internet anda.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('Kesalahan pada perangkat.');
    }
  }

  Future<http.Response> getUsersData({@required String token}) async {
    try {
      return await http.get(
        baseUrl + 'apps/users',
        headers: {'Authorization': token},
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> getRGData({
    @required String token,
    bool month = false,
    bool today = false,
  }) async {
    String additionalUrl = '';

    if (month) {
      additionalUrl = '?month=1';
    } else if (today) {
      additionalUrl = '?today=1';
    }

    try {
      return await http.get(
        baseUrl + 'apps/rencana-giat/potensi/data' + additionalUrl,
        headers: {'Authorization': token},
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> getRGDetail({
    @required String token,
    @required String uid,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/rencana-giat/potensi/detil/' + uid,
        headers: {'Authorization': token},
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> getRGFinish({
    @required String token,
    @required String uid,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/rencana-giat/potensi/selesaikan/' + uid,
        headers: {'Authorization': token},
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> getRGDelete({
    @required String token,
    @required String uid,
  }) async {
    try {
      return await http.delete(
        baseUrl + 'apps/rencana-giat/potensi/hapus/' + uid,
        headers: {'Authorization': token},
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> getKamtibmasData({
    @required String token,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/rencana-giat/kamtibmas/data',
        headers: {'Authorization': token},
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> postLaporanURL({
    @required String token,
    @required Map body,
    @required String uid,
  }) async {
    print(body);
    try {
      return await http.post(
        baseUrl + 'apps/potensi-konflik/laporan/informasi/' + uid,
        headers: {'Authorization': token},
        body: body,
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }

  Future<http.Response> getLaporanDetail({
    @required String token,
    @required String uid,
  }) async {
    try {
      return await http.get(
        baseUrl + 'apps/potensi-konflik/laporan/informasi/' + uid,
        headers: {'Authorization': token},
      );
    } on TimeoutException catch (e) {
      print(e);
      return Future.error('TimeoutException: Request timeout.');
    } on SocketException catch (e) {
      print(e);
      return Future.error('SocketException: Periksa koneksi internet.');
    } on http.ClientException catch (e) {
      print(e);
      return Future.error('ClientException: Kesalahan pada klien.');
    }
  }
}
