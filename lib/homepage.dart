import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nomorController = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final _daftarBox = Hive.box('daftar_anggota');

  @override
  void initState() {
    // Load data when app starts
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _daftarBox.keys.map((key) {
      final item = _daftarBox.get(key);
      return {"key": key, "nama": item['nama'], "nomor": item['nomor']};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  //create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _daftarBox.add(newItem);
    _refreshItems();
  }

  //update item
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _daftarBox.put(itemKey, item);
    _refreshItems();
  }

  //delete item
  Future<void> _deleteItem(int itemKey) async {
    await _daftarBox.delete(itemKey);
    _refreshItems();

    //display a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('An item successfully dellete')));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    //
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _namaController.text = existingItem['nama'];
      _nomorController.text = existingItem['nomor'];
    }

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(hintText: 'Nama'),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _nomorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Nomor'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (itemKey == null) {
                    _createItem({
                      "nama": _namaController.text,
                      "nomor": _nomorController.text
                    });
                  }

                  if (itemKey != null) {
                    _updateItem(itemKey, {
                      'nama': _namaController.text.trim(),
                      'nomor': _nomorController.text.trim()
                    });
                  }

                  //clear the text fields
                  _namaController.text = '';
                  _nomorController.text = '';

                  Navigator.of(context).pop();
                },
                child: Text(itemKey == null ? 'Create new' : 'Update')),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hive'),
      ),
      body: ListView.builder(
        // the list of items
        itemCount: _items.length,
        itemBuilder: (_, index) {
          final currebtItem = _items[index];
          return Card(
            color: Colors.blue[200],
            margin: EdgeInsets.all(10),
            elevation: 3,
            child: ListTile(
              title: Text(
                currebtItem['nama'],
              ),
              subtitle: Text(currebtItem['nomor'].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //edit button
                  IconButton(
                      onPressed: () => _showForm(context, currebtItem['key']),
                      icon: Icon(Icons.edit)),
                  //delete button
                  IconButton(
                      onPressed: () => _deleteItem(currebtItem['key']),
                      icon: Icon(Icons.delete))
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}
