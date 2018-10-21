import 'package:flutter/material.dart';
import 'license.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Ember Watch',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: 'Ember Watch'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Ember Watch')),
        body: new Text(''),
        drawer: new Drawer(
          child: new ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              new DrawerHeader(
                  child: new Text('Menu'),
                  decoration: new BoxDecoration(color: Colors.red)),
              new ListTile(
                  title: new Text('Settings'),
                  onTap: () {
                    //update state of app
                  }),
              new ListTile(
                title: new Text('License'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new LicensePg()));


                }),
            ],
          ),
        ));
  }
}
