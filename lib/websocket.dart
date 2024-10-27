import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TimetableFetcher {
  final io.Socket socket;
  List<dynamic> nextUpTrains = [];
  List<dynamic> nextDownTrains = [];

  TimetableFetcher()
      : socket = io.io(dotenv.env['SERVER_URL'], <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true,
        }) {
    socket.on('connect', (_) {
      socket.emit('getTimetable');
    });

    socket.on('onTimetable', (data) {
      nextUpTrains = List<dynamic>.from(data['nextUpTrains'])
          .map((train) => {
                ...train,
                'time': formatTime(train['time']), // 整形された時間
              })
          .toList();
      nextDownTrains = List<dynamic>.from(data['nextDownTrains'])
          .map((train) => {
                ...train,
                'time': formatTime(train['time']), // 整形された時間
              })
          .toList();
    });

    socket.on('connect_error', (data) {
      //print("エラーが発生しました: $data");
    });
  }

  Future<List<dynamic>> getNextUpTrains() async {
    final completer = Completer<List<dynamic>>();
    
    socket.emit('getTimetable');
    socket.once('onTimetable', (data) {
      nextUpTrains = List<dynamic>.from(data['nextUpTrains'])
          .map((train) => {
                ...train,
                'time': formatTime(train['time']), // 整形された時間
              })
          .toList();
      completer.complete(nextUpTrains);
    });

    return completer.future;
  }

  Future<List<dynamic>> getNextDownTrains() async {
    final completer = Completer<List<dynamic>>();
    
    socket.emit('getTimetable');
    socket.once('onTimetable', (data) {
      nextDownTrains = List<dynamic>.from(data['nextDownTrains'])
          .map((train) => {
                ...train,
                'time': formatTime(train['time']), // 整形された時間
              })
          .toList();
      completer.complete(nextDownTrains);
    });

    return completer.future;
  }

  // 時間を整形するヘルパー関数
  String formatTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return '${parts[0]}:${parts[1].padLeft(2, '0')}'; // 分を2桁にする
    }
    return time; // 予期しない形式の場合はそのまま返す
  }
}
