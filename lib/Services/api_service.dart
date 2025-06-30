import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = 'https://api.weatherapi.com/v1';

  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7',
    );
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch data: ${res.body}');
    }

    final data = json.decode(res.body);

    // Check if API returned an error (invalid location)
    if (data.containsKey('error')) {
      throw Exception(data['error']['message'] ?? 'Invalid location');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getPastSevenDaysWeather(
    String location,
  ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();

    for (int i = 1; i <= 7; i++) {
      final date = today.subtract(Duration(days: i));
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final url = Uri.parse(
        '$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data.containsKey('error')) {
          // Skip this date if location invalid or no data
          throw Exception(data['error']['message'] ?? 'Invalid location');
        }
        if (data['forecast']?['forecastday'] != null) {
          pastWeather.add(data);
        }
      } else {
        debugPrint('Failed to fetch past data for $formattedDate: ${res.body}');
      }
    }

    return pastWeather;
  }
}

// lib/api_key.dart
const String apiKey = "4d1c383e514f4e1ea6154708253105";
