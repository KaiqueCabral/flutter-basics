import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      title: 'Flutter - ToDo List',
      theme: ThemeData(
        primarySwatch: Colors.green,
        focusColor: Colors.white,
        cursorColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController newTaskControl = TextEditingController();
  FocusNode _focusNode = FocusNode(
    canRequestFocus: true,
  );

  add() {
    if (newTaskControl.text.isEmpty) {
      FocusScope.of(context).requestFocus(_focusNode);
      return;
    }

    setState(() {
      widget.items.add(
        Item(
          title: newTaskControl.text,
          done: false,
        ),
      );
      newTaskControl.text = "";
      save();
    });
  }

  remove(index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var preferences = await SharedPreferences.getInstance();
    var data = preferences.getString("data");

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString("data", jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskControl,
          focusNode: _focusNode,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            decorationColor: Colors.white,
          ),
          decoration: InputDecoration(
            labelText: "New Task",
            focusColor: Colors.white,
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Tooltip(
              message: "Click here to add a task",
              showDuration: Duration(seconds: 2),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            onPressed: add,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            key: Key(item.title),
            background: Container(
              color: Colors.red[100],
            ),
            child: CheckboxListTile(
              title: Text(item.title),
              key: Key(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            onDismissed: (DismissDirection direction) {
              remove(index);
            },
          );
        },
      ),
    );
  }
}
