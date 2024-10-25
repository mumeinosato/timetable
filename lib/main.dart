import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'websocket.dart';
import 'dart:async';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: '東静岡駅 電車状況'),
      home: MyHomePage(title: '${dotenv.env['STATION_NAME']}駅 電車状況'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TimetableFetcher timetableFetcher;
  List<dynamic> nextUpTrains = [];
  List<dynamic> nextDownTrains = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timetableFetcher = TimetableFetcher();

    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      fetchTimetableData();
    });

    fetchTimetableData();
  }

  void fetchTimetableData() {
    setState(() {
      nextUpTrains = timetableFetcher.getNextUpTrains();
      nextDownTrains = timetableFetcher.getNextDownTrains();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: Column(children: <Widget>[
        Container(
          height: 2.0,
          color: Colors.white,
        ),
        const SizedBox(height: 20),
        const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '浜松・島田方面',
                style: TextStyle(color: Colors.white, fontSize: 30),
                textAlign: TextAlign.right,
              ),
            )),
        if (nextDownTrains.isNotEmpty)
          Text(
            '${nextDownTrains[0]["time"]}発 ${nextDownTrains[0]["destination"]}行き',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        const SizedBox(height: 20),
        Container(
          height: 2.0,
          color: const Color.fromARGB(255, 36, 20, 20),
        ),
        const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '熱海・興津方面',
                style: TextStyle(color: Colors.white, fontSize: 30),
                textAlign: TextAlign.right,
              ),
            )),
        const SizedBox(height: 20),
      ])),
      floatingActionButton: null,
    );
  }
}
