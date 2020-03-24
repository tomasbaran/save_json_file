import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

const String kFileName = 'myJsonFile.json';
const InputDecoration kInputDecoration = InputDecoration(
  border: OutlineInputBorder(),
  labelText: 'Label Text',
);
const TextStyle kInputTextStyle = TextStyle(
  fontSize: 22,
  color: Colors.blue,
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _controllerKey, _controllerValue;
  bool _fileExists = false;
  File _filePath;

  // First initialization of _json (if there is no json in the file)
  Map<dynamic, dynamic> _json = {};
  String _jsonListString;

  // Initialization of List<_jsons>
  List<dynamic> _jsonList = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$kFileName');
  }

  void _writeJsonRecord(Map<dynamic, dynamic> _jsonInput) {
    // 0. Get the _json
    print('0.(_writeJsonRecord) _json: $_jsonInput');

    // 1. Add new json to the List<_json>
    _jsonList.add(_jsonInput);
    print('1.(_writeJsonRecord) _jsonList: $_jsonList');

    // 2. Convert _jsonList->_jsonListString
    _jsonListString = jsonEncode(_jsonList);
    print('2a.(_writeJsonRecord) _jsonListString: $_jsonListString \n \n -');

    // 3. Write _jsonListString into the file
    _filePath.writeAsString(_jsonListString);
  }

  void _writeJsonPair(String key, dynamic value) {
    // Initialize the local _filePath
    //final _filePath = await _localFile;

    //1. Create _newJsonPair<Map> from input<TextField>
    Map<String, dynamic> _newJsonPair = {key: value};
    print('1.(_writeJson) _newJsonPair: $_newJsonPair');

    //2. Update _json by adding _newJsonPair<Map> -> _json<Map>
    print('2a.(_writeJson) _json(before being updated): $_json');
    _json.addAll(_newJsonPair);
    print('2b.(_writeJson) _json(updated): $_json \n\n -');
  }

  void _readJson() async {
    // Initialize _filePath
    _filePath = await _localFile;

    // 0. Check whether the _file exists
    _fileExists = await _filePath.exists();
    print('0. File exists? $_fileExists');

    //1. If the _file exists->read it: update initialized _json by what's in the _file
    if (_fileExists) {
      try {
        //1. Read _jsonListString<String> from the _file.
        _jsonListString = await _filePath.readAsString();
        print('1.(_readJson) _jsonListString: $_jsonListString');

        //2. Update initialized _jsonList by converting _jsonListString<String>->_jsonList<Map>
        _jsonList = jsonDecode(_jsonListString);
        print('2.(_readJson) _jsonList: $_jsonList');
      } catch (e) {
        // Print exception errors
        print('Tried reading _file error: $e');
        // If encountering an error, return null
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Instantiate _controllerKey and _controllerValue
    _controllerKey = TextEditingController();
    _controllerValue = TextEditingController();
    print('0. Initialized _jsonList: $_jsonList');
    _readJson();
  }

  @override
  void dispose() {
    _controllerKey.dispose();
    _controllerValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create JSON File'),
        ),
        body: SafeArea(
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'JSON:',
                textAlign: TextAlign.center,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                child: Text(
                  _json.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'Add to JSON file',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(fontWeight: FontWeight.w700, color: Colors.blue),
              ),
              MyInputWidget(
                controller: _controllerKey,
                label: 'Key',
              ),
              MyInputWidget(
                controller: _controllerValue,
                label: 'Value',
              ),
              SizedBox(
                height: 15,
              ),
              RaisedButton(
                onPressed: () {
                  print(
                      '0. Input key: ${_controllerKey.text}; Input value: ${_controllerValue.text}');
                  _writeJsonPair(_controllerKey.text, _controllerValue.text);

                  setState(() {});
                  _controllerKey.clear();
                  _controllerValue.clear();
                },
                elevation: 25.0,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                //shape: ShapeBorder(),
                color: Theme.of(context).primaryColor,
                child: Text(
                  'Add {Key, Value} pair',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RaisedButton(
                onPressed: () {
                  _writeJsonRecord(_json);
                  // Clear _json for the new _json
                  _json = {};
                  setState(() {});
                },
                elevation: 25.0,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                //shape: ShapeBorder(),
                color: Colors.red,
                child: Text(
                  'Write Blue Json Record to file',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  _jsonList.toString(),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  MyInputWidget({this.controller, this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 15,
      ),
      child: TextField(
        controller: controller,
        decoration: kInputDecoration.copyWith(labelText: label),
        style: kInputTextStyle,
      ),
    );
  }
}
