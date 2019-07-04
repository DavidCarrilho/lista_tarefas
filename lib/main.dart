import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

// Add Tarefa =====================================================================
  void _addTodo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _todoController.text;
      _todoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      // verificar se foi digitado alguma tarefa, caso constrario aparecer uma mensagem
      // if(newToDo["title"] == ""){}
      _saveData();
    });
  }

  // // Deletar a Lista ================================================================================
  // void _deleteData() async {
  //   // String data = json.encode(_toDoList);

  //   final file = await _getFile();
  //   return file.delete();
  //     _saveData();
  // }

// Atualiza a Tela =====================================================================
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

// Precisa Retorna 1 se a > b; 0 se a == b ; -1 se a < b
    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(17, 1, 7, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                          labelText: 'Nova Tarefa',
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    child: Text('ADD'),
                    textColor: Colors.white,
                    onPressed: _addTodo,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    // Arrasta o Item para direita para remover ================================================
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]["ok"] ? Icons.check : Icons.error,
          ),
          // backgroundColor: Colors.red,
        ),
        onChanged: (checked) {
          print(checked);
          setState(() {
            _toDoList[index]["ok"] = checked;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          //Duplica o intem que quer remover
          _lastRemoved = Map.from(_toDoList[index]);
          //guarda ao posiçaõ
          _lastRemovedPos = index;
          //remove nesta posição
          _toDoList.removeAt(index);
          //salva a lista com essa nova listagem
          _saveData();

          final snack = SnackBar(
            content: Text('Tarefa ${_lastRemoved["title"]} removida!'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

// Cria o File em Json =====================================================================
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

// Salva File ================================================================================
  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

// Read File ================================================================================
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
