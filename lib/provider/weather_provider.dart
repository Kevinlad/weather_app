import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/api/weatherApi.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  ApiResponse? _response;
  bool _inProgress = false;
  String _message = "Search for the location to get weather data";
  List<String> _lastSearchedCities = [];

  ApiResponse? get response => _response;
  bool get inProgress => _inProgress;
  String get message => _message;
  List<String> get lastSearchedCities => _lastSearchedCities;

  WeatherProvider() {
    _loadLastSearchedCities();
  }

  Future<void> _loadLastSearchedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cities = prefs.getStringList('lastSearchedCities');
    if (cities != null && cities.isNotEmpty) {
      _lastSearchedCities = cities;
      await getWeatherData(cities.last);
    }
    notifyListeners();
  }

  Future<void> _saveLastSearchedCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_lastSearchedCities.contains(city)) {
      _lastSearchedCities.remove(city);
    }
    _lastSearchedCities.add(city);
    if (_lastSearchedCities.length > 3) {
      _lastSearchedCities.removeAt(0);
    }
    await prefs.setStringList('lastSearchedCities', _lastSearchedCities);
    notifyListeners();
  }

  Future<void> getWeatherData(String location) async {
    _inProgress = true;
    notifyListeners();

    try {
      _response = await WeatherApi().getCurrentWeather(location);
      await _saveLastSearchedCity(location);
    } catch (e) {
      _message = "Please enter the correct city name";
      _response = null;
    } finally {
      _inProgress = false;
      notifyListeners();
    }
  }
}
