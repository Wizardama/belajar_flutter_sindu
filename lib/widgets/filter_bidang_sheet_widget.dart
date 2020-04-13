import 'package:digimap_pandonga/core/models/login_model.dart';
import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/datasource/API.dart';
import 'package:digimap_pandonga/core/models/filter_model.dart';
import 'package:digimap_pandonga/core/models/singleton_model.dart';


class FilterBidangSheetWidget extends StatefulWidget {
  final int bidangValue;
  final int kategoriValue;
  final Function filterFunction;

  FilterBidangSheetWidget({
    @required this.bidangValue,
    @required this.kategoriValue,
    @required this.filterFunction,
  });

  @override
  _FilterBidangSheetWidgetState createState() => _FilterBidangSheetWidgetState();
}

class _FilterBidangSheetWidgetState extends State<FilterBidangSheetWidget> {
  LoginModel _loginModel = LoginModel.fromJson(SingletonModel.shared.login);

  API _api = API();
  bool _connectionProgres = true;
  String _errorMessage;
  FilterModel _filter;

  // Filter value handle
  int _bidangValue;
  int _kategoriValue;

  void _loadFilterData() {
    if (SingletonModel.shared.filter != null) {
      _filter = FilterModel.fromJson(SingletonModel.shared.filter);
      _connectionProgres = false;
    } else {
      _api.getFilterData(token: _loginModel.token).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            SingletonModel.shared.filter = response.body;
            _filter = FilterModel.fromJson(response.body);
            _connectionProgres = false;
          });
        }
      }).catchError((error) {
        setState(() {
          _connectionProgres = false;
          _errorMessage = error.toString();
        });
      });
    }

    _bidangValue = widget.bidangValue;
    _kategoriValue = widget.kategoriValue;
  }

  List<ItemFilter> _loadFilterBidang() {
    List<ItemFilter> filter = new List();

    filter.add(ItemFilter('Tanpa filter bidang', 0));

    _filter.bidang.list.forEach((f) {
      filter.add(ItemFilter(f.namaBidang, f.id));
    });

    return filter;
  }

  List<ItemFilter> _loadFilterKategori() {
    List<ItemFilter> filter = new List();

    filter.add(ItemFilter('Tanpa filter kategori', 0));

    _filter.kategori.list.forEach((f) {
      if (f.idBidang == _bidangValue) {
        filter.add(ItemFilter(f.namaKategori, f.id));
      }
    });

    return filter;
  }

  @override
  void initState() {
    super.initState();
    _loadFilterData();
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionProgres) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (_errorMessage != null) {
        return Container();
      } else {
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          children: <Widget>[
            SizedBox(height: 8.0),
            Text(
              'Filter'.toUpperCase(),
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.0),
            Text('Pilih Bidang:'),
            Container(
              child: DropdownButton<int>(
                value: _bidangValue,
                iconSize: 24,
                elevation: 16,
                onChanged: (value) {
                  setState(() {
                    _bidangValue = value;

                    // reset kategori
                    _kategoriValue = null;
                  });
                },
                hint: Text('Bidang'),
                isExpanded: true,
                itemHeight: 64.0,
                items: _loadFilterBidang().map<DropdownMenuItem<int>>(
                  (ItemFilter f) {
                    return DropdownMenuItem<int>(
                      value: f.value,
                      child: Text(
                        f.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: 16.0),
            Text('Pilih Kategori:'),
            Container(
              child: DropdownButton<int>(
                value: _kategoriValue,
                iconSize: 24,
                elevation: 16,
                onChanged: (value) {
                  setState(() {
                    _kategoriValue = value;
                  });
                },
                hint: Text('Kategori'),
                isExpanded: true,
                itemHeight: 64.0,
                items: _loadFilterKategori().map<DropdownMenuItem<int>>(
                  (ItemFilter f) {
                    return DropdownMenuItem<int>(
                      value: f.value,
                      child: Text(
                        f.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: 16.0),
            FlatButton(
              color: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              onPressed: () {
                widget.filterFunction(
                  _bidangValue,
                  _kategoriValue,
                );
                Navigator.pop(context);
              },
              child: Text(
                'Atur Filter',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        );
      }
    }
  }
}

class ItemFilter {
  final String title;
  final int value;

  ItemFilter(this.title, this.value);
}
