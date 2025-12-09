import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interface/schedule.dart';

class ScheduleService {
  Future<List<Schedule>> fetchSchedule(String stationId) async {
    final url = Uri.parse("https://www.api.comuline.com/v1/schedule/$stationId");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      List data = decoded["data"];

      return data.map((e) => Schedule.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load schedules");
    }
  }
}
