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
      //print(data);
      nextUpTrains = List<dynamic>.from(data['nextUpTrains']);
      nextDownTrains = List<dynamic>.from(data['nextDownTrains']);
    });

    socket.on('connect_error', (data) {
      //print("エラーが発生しました: $data");
    });
  }

  List<dynamic> getNextUpTrains() {
    return nextUpTrains.isNotEmpty ? nextUpTrains : [];
  }

  List<dynamic> getNextDownTrains() {
    return nextDownTrains.isNotEmpty ? nextDownTrains : [];
  }
}
