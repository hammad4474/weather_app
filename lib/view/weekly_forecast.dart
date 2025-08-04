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
  String formatApiData(String? dataString) {
    if (dataString == null || dataString.isEmpty) {
      return 'Unknown date';
    }
    try {
      DateTime date = DateTime.parse(dataString);
      return DateFormat('d MMMM, EEEE').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weekly Forecast',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
                      '${widget.currentValue['temp_c'] ?? 'N/A'}°C',
                      style: TextStyle(
                        fontSize: 50,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${widget.currentValue['condition']?['text'] ?? 'Loading...'}",
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    if (widget.currentValue['condition']?['icon'] != null)
                      Image.network(
                        'https:${widget.currentValue['condition']['icon']}',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.cloud,
                            size: 150,
                            color: Theme.of(context).colorScheme.secondary,
                          );
                        },
                      )
                    else
                      Icon(
                        Icons.cloud,
                        size: 150,
                        color: Theme.of(context).colorScheme.secondary,
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
              if (widget.next7days.isNotEmpty)
                ...widget.next7days.map((day) {
                  if (day == null) return SizedBox.shrink();
                  final data = day['date'];
                  final condition =
                      day['day']?['condition']?['text'] ?? 'No data';
                  final icon = day['day']?['condition']?['icon'] ?? '';
                  final maxTemp = day['day']?['maxtemp_c'] ?? 'N/A';
                  final mintemp = day['day']?['mintemp_c'] ?? 'N/A';

                  return ListTile(
                    leading:
                        icon.isNotEmpty
                            ? Image.network(
                              'https:$icon',
                              width: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.cloud,
                                  size: 40,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                );
                              },
                            )
                            : Icon(
                              Icons.cloud,
                              size: 40,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                    title: Text(
                      data != null ? formatApiData(data) : 'Unknown date',
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
                })
              else
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No forecast data available',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              Text(
                'Past 7 Days Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 10),
              if (widget.pastWeek.isNotEmpty)
                ...widget.pastWeek.map((day) {
                  if (day == null) return SizedBox.shrink();
                  final forecastDay = day['forecast']?['forecastday'];
                  if (forecastDay == null || forecastDay.isEmpty) {
                    return SizedBox.shrink();
                  }
                  final forecast = forecastDay[0];
                  final data = forecast?['date'];
                  final condition =
                      forecast?['day']?['condition']?['text'] ?? 'No data';
                  final icon = forecast?['day']?['condition']?['icon'] ?? '';
                  final maxTemp = forecast?['day']?['maxtemp_c'] ?? 'N/A';
                  final mintemp = forecast?['day']?['mintemp_c'] ?? 'N/A';

                  return ListTile(
                    leading:
                        icon.isNotEmpty
                            ? Image.network(
                              'https:$icon',
                              width: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.cloud,
                                  size: 40,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                );
                              },
                            )
                            : Icon(
                              Icons.cloud,
                              size: 40,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                    title: Text(
                      data != null ? formatApiData(data) : 'Unknown date',
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
                })
              else
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No historical data available',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              // Add bottom padding to ensure content doesn't touch navigation bar
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
