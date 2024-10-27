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
      home: MyHomePage(title: '${dotenv.env['STATION']}駅 電車状況'),
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

  void fetchTimetableData() async {
    final upTrains = await timetableFetcher.getNextUpTrains();
    final downTrains = await timetableFetcher.getNextDownTrains();
    setState(() {
      nextUpTrains = upTrains;
      nextDownTrains = downTrains;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左寄せに設定
          children: <Widget>[
            Container(
              height: 2.0,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // DOWN方面
            buildTrainDirectionHeader(
                dotenv.env['DOWN'] ?? '下り', Alignment.centerRight),
            const SizedBox(height: 10),
            if (nextDownTrains.isNotEmpty) ...[
              buildTrainInfoRow(
                  '${nextDownTrains[0]["time"]}発 ${nextDownTrains[0]["destination"]}行き'),
              buildRightAlignedInfo(
                  'あと${nextDownTrains[0]["rest"]}分 ${nextDownTrains[0]["status"]}'),
              buildTrainInfoRow(
                  '${nextDownTrains[1]["time"]}発 ${nextDownTrains[1]["destination"]}行き'),
              buildRightAlignedInfo(
                  'あと${nextDownTrains[1]["rest"]}分 ${nextDownTrains[1]["status"]}'),
            ],
            const SizedBox(height: 20),
            Container(
              height: 2.0,
              color: const Color.fromARGB(255, 36, 20, 20),
            ),
            // UP方面
            const SizedBox(height: 20),
            buildTrainDirectionHeader(
                dotenv.env['UP'] ?? '上り', Alignment.centerRight),
            const SizedBox(height: 10),
            if (nextUpTrains.isNotEmpty) ...[
              buildTrainInfoRow(
                  '${nextUpTrains[0]["time"]}発 ${nextUpTrains[0]["destination"]}行き'),
              buildRightAlignedInfo(
                  'あと${nextUpTrains[0]["rest"]}分 ${nextUpTrains[0]["status"]}'),
              buildTrainInfoRow(
                  '${nextUpTrains[1]["time"]}発 ${nextUpTrains[1]["destination"]}行き'),
              buildRightAlignedInfo(
                  'あと${nextUpTrains[1]["rest"]}分 ${nextUpTrains[1]["status"]}'),
            ],
          ],
        ),
      ),
      floatingActionButton: null,
    );
  }

  // 方向ヘッダーを作成するヘルパー関数
  Widget buildTrainDirectionHeader(String title, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 30),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  // 電車情報を1行で表示するヘルパー関数（行きが改行されないように調整）
  Widget buildTrainInfoRow(String trainInfo) {
    return Padding(
      padding: const EdgeInsets.only(left: 20), // 左寄せの余白
      child: Text(
        trainInfo,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  // ステータス情報を右寄せで表示するヘルパー関数
  Widget buildRightAlignedInfo(String infoText) {
    Color textColor;

    // ステータスに応じた色を設定
    if (infoText.contains('あきらめましょう')) {
      textColor = Colors.red; // 赤
    } else if (infoText.contains('走れば間に合います')) {
      textColor = Colors.yellow; // 黄色
    } else if (infoText.contains('歩いても間に合います')) {
      textColor = Colors.lightBlue; // 水色
    } else {
      textColor = Colors.white; // デフォルトの色
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Text(
          infoText,
          style: TextStyle(color: textColor, fontSize: 20), // 色を設定
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
