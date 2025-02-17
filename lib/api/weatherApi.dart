import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/constant.dart';
import 'package:weather_app/models/weather_model.dart';



class WeatherApi {
  final String baseUrl = "http://api.weatherapi.com/v1/current.json";

  Future<ApiResponse> getCurrentWeather(String location) async {
    // url of the api
    String apiUrl = "$baseUrl?key=$apikey&q=$location";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load weather");
      }
    } catch (e) {
      throw Exception("Failed to load weather");
    }
  }
}