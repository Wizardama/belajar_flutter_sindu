import 'dart:convert';

class LoginModel {
  final String uid;
  final String foto;
  final String email;
  final String username;
  final String noTelepon;
  final String nama;
  final String pangkat;
  final String wilayah;
  final String hakAkses;
  final int idAkses;
  final String token;

  LoginModel(
    this.uid,
    this.foto,
    this.email,
    this.username,
    this.noTelepon,
    this.nama,
    this.pangkat,
    this.wilayah,
    this.hakAkses,
    this.idAkses,
    this.token,
  );

  factory LoginModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return LoginModel(
      data['user']['uid'],
      data['user']['foto'],
      data['user']['email'],
      data['user']['username'],
      data['user']['no_telp'],
      data['user']['nama'],
      data['user']['pangkat'],
      data['user']['nama_wilayah'],
      data['user']['hak_akses'],
      data['user']['id_akses'],
      data['access_token'],
    );
  }
}
