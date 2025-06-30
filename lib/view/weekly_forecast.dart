import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyForecast extends StatefulWidget {
  final String city;
  final Map<String, dynamic> currentValue;
  final List<dynamic> hourly;
  final List<dynamic> pastWeek;
  final List<dynamic> next7days;
  const WeeklyForecast({
    super.key,
    required this.currentValue,
    required this.hourly,
    required this.pastWeek,
    required this.next7days,
    required this.city,
  });

  @override
  State<WeeklyForecast> createState() => _WeeklyForecastState();
}

class _WeeklyForecastState extends State<WeeklyForecast> {
  String formatApiData(String dataString) {
    DateTime date = DateTime.parse(dataString);
    return DateFormat('d MMMM, EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.city,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${widget.currentValue['temp_c']}°C',
                      style: TextStyle(
                        fontSize: 50,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${widget.currentValue['condition']['text']}",
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Image.network(
                      'https:${widget.currentValue['condition']?['icon'] ?? ''}',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Next 7 Days Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 10),
              ...widget.next7days.map((day) {
                final data = day['date'];
                final condition = day['day']?['condition']?['text'] ?? '';
                final icon = day['day']?['condition']?['icon'] ?? '';
                final maxTemp = day['day']?['maxtemp_c'] ?? '';
                final mintemp = day['day']?['mintemp_c'] ?? '';
                return ListTile(
                  leading: Image.network('https:$icon', width: 40),
                  title: Text(
                    formatApiData(data),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  subtitle: Text(
                    "$condition $mintemp°C - $maxTemp°C",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }),
              Text(
                'Past 7 Days Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 10),
              ...widget.pastWeek.map((day) {
                final forecastDay = day['forecast']?['forecastday'];
                if (forecastDay == null || forecastDay.isEmpty) {
                  return SizedBox.shrink();
                }
                final forecast = forecastDay[0];
                final data = forecast['date'];
                final condition = forecast['day']?['condition']?['text'] ?? '';
                final icon = forecast['day']?['condition']?['icon'] ?? '';
                final maxTemp = forecast['day']?['maxtemp_c'] ?? '';
                final mintemp = forecast['day']?['mintemp_c'] ?? '';
                return ListTile(
                  leading: Image.network('https:$icon', width: 40),
                  title: Text(
                    formatApiData(data),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  subtitle: Text(
                    "$condition $mintemp°C - $maxTemp°C",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
