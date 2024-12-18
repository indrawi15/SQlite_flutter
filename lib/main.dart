import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _controller = TextEditingController();
  List<String> _fileContent = [];

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.txt');
  }

  Future<void> _saveData() async {
    final file = await _getFile();
    String newData = _controller.text.trim();

    if (newData.isNotEmpty) {
      await file.writeAsString('$newData\n', mode: FileMode.append);
      _readData();
      _controller.clear();
    }
  }

  Future<void> _readData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        String content = await file.readAsString();
        setState(() {
          _fileContent = content.isNotEmpty ? content.trim().split('\n') : ["No data available"];
        });
      } else {
        setState(() {
          _fileContent = ["No data available"];
        });
      }
    } catch (e) {
      setState(() {
        _fileContent = ["Error reading file"];
      });
    }
  }

  Future<void> _deleteData() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
      setState(() {
        _fileContent = ["No data available"];
      });
    }
  }

  Future<void> _deleteSpecificData(String item) async {
    _fileContent.remove(item); // Hapus item dari list
    final file = await _getFile();
    await file.writeAsString(_fileContent.join('\n')); // Tulis ulang file tanpa item tersebut
    setState(() {}); // Perbarui UI
  }

  @override
  void initState() {
    super.initState();
    _readData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('File Storage Example'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "File Content:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _fileContent.isEmpty || (_fileContent.length == 1 && _fileContent[0] == "No data available")
                  ? Container(
                width: double.infinity,
                color: Colors.grey[300],
                padding: EdgeInsets.all(8),
                child: Text(
                  "No data available",
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _fileContent.length,
                itemBuilder: (context, index) {
                  String item = _fileContent[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis, // Jika teks terlalu panjang
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteSpecificData(item);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          icon: Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Enter data to save",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _saveData,
                    child: Text("Save Data"),
                  ),
                  ElevatedButton(
                    onPressed: _readData,
                    child: Text("Read Data"),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: _deleteData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text("Delete All Data"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
