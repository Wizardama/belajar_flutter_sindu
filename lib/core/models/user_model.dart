import 'dart:convert';

class UserModel {
  final String uid;
  final String nama;
  final String pangkat;

  UserModel(this.uid, this.nama, this.pangkat);

  factory UserModel.fromJson(String jsonData) {
    final data = json.decode(jsonData);

    return UserModel(data['uid'], data['nama'], data['pangkat']);
  }
}

class UserModels {
  final List<UserModel> list;

  UserModels(this.list);

  factory UserModels.fromJson(String jsonData) {
    final data = json.decode(jsonData);
    final listData = data['users'] as List;
    List<UserModel> list =
        listData.map((f) => UserModel.fromJson(json.encode(f))).toList();

    return UserModels(list);
  }
}
