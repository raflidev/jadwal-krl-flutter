import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interface/station.dart';

class StationService {
  Future<List<Station>> fetchStations() async {
    final url = Uri.parse("https://www.api.comuline.com/v1/station");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      List data = decoded["data"];

      return data.map((e) => Station.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load stations");
    }
  }
}
