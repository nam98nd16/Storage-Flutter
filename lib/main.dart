import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences prefs;
  late bool didInit = false;
  late bool didInit2 = false;
  late bool didInit3 = false;
  final myController = TextEditingController();
  final myController2 = TextEditingController();
  late String localPath;
  late Database db;
  var store = StoreRef.main();
  late String loverName;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    initLocalPath();
    initDb();
  }

  void initSharedPref() async {
    // obtain shared preferences
    prefs = await SharedPreferences.getInstance();
    didInit = true;
  }

  void initLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    localPath = directory.path;
    print("path" + localPath);
    didInit2 = true;
  }

  void initDb() async {
    // get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = join(dir.path, 'my_database.db');
    // open the database
    db = await databaseFactoryIo.openDatabase(dbPath);
  }

  void setLoverName() async {
    var lover = await store.record('lover').get(db) as String;
    loverName = lover;
    didInit3 = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: myController,
                      decoration:
                          new InputDecoration(hintText: "Enter your name ..."),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        prefs.setString("name", myController.text);
                      });
                    },
                    child: Text("Save to SharedPrefs"))
              ],
            ),
            Row(
              children: [
                Text("Your name retrieved from SharedPrefs is "),
                didInit ? Text(prefs.getString("name") ?? "") : Container()
              ],
            ),
            didInit2
                ? Text("Current working directory is " + localPath)
                : Container(),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: myController2,
                      decoration:
                          new InputDecoration(hintText: "Enter your lover ..."),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      await store.record('lover').put(db, myController2.text);
                    },
                    child: Text("Add to Sembast db")),
              ],
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        setLoverName();
                      });
                    },
                    child: Text("Get your lover's name from Sembast db")),
                didInit3 ? Text(loverName) : Container()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
