import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/Providers/theme_provider.dart';
import 'package:weather_app/Services/api_service.dart';
import 'package:weather_app/Services/location_service.dart';
import 'package:weather_app/view/weekly_forecast.dart';
import 'package:weather_app/utils/page_transitions.dart';

class WeatherAppHomescreen extends ConsumerStatefulWidget {
  const WeatherAppHomescreen({super.key});

  @override
  ConsumerState<WeatherAppHomescreen> createState() =>
      _WeatherAppHomescreenState();
}

class _WeatherAppHomescreenState extends ConsumerState<WeatherAppHomescreen> {
  final _weatherServices = WeatherService();
  final _locationService = LocationService();
  String city = 'Loading location...';
  String country = '';
  Map<String, dynamic> currentValue = {};
  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7days = [];
  bool isLoading = false;
  bool isLocationLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndFetchWeather();
  }

  Future<void> _getCurrentLocationAndFetchWeather() async {
    setState(() {
      isLocationLoading = true;
      isLoading = true;
    });

    try {
      // Add overall timeout to prevent ANR
      print('🗺️ Getting current location...');

      String currentLocationCity = await _locationService
          .getCurrentLocationCity()
          .timeout(
            Duration(seconds: 8), // Maximum 8 seconds total
            onTimeout: () {
              throw Exception('Location detection timed out');
            },
          );

      if (mounted) {
        setState(() {
          city = currentLocationCity;
          isLocationLoading = false;
        });

        print('📍 Location found: $currentLocationCity');
        await _fetchWeather();
      }
    } catch (e) {
      print('❌ Location error: $e');

      if (mounted) {
        // Fallback to default location if GPS fails
        setState(() {
          city = 'Islamabad,Pakistan'; // Fallback city
          isLocationLoading = false;
        });

        // Show user-friendly message
        Get.snackbar(
          'Location Notice',
          'Using default location. Tap the location button to try again.',
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 8,
        );

        await _fetchWeather();
      }
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final forecast = await _weatherServices.getHourlyForecast(city);
      final past = await _weatherServices.getPastSevenDaysWeather(city);

      setState(() {
        currentValue = forecast['current'] ?? {};
        hourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];

        next7days = forecast['forecast']?['forecastday'] ?? [];
        pastWeek = past;
        city = forecast['location']?['name'] ?? city;
        country = forecast['location']?['country'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        pastWeek = [];
        next7days = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('City not found. Please enter a valid city name'),
        ),
      );
    }
  }

  String formateTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final themeType = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeType == ThemeType.dark;

    String iconPath = currentValue['condition']?['icon'] ?? '';
    String imageUrl = iconPath.isNotEmpty ? 'https:$iconPath' : '';
    Widget imageWidget =
        imageUrl.isNotEmpty
            ? Image.network(
              imageUrl,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
            : SizedBox();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        toolbarHeight: Get.height * 0.08, // Responsive height
        flexibleSpace: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.04, // Responsive padding
            vertical: Get.height * 0.01,
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Search TextField - takes most space
                Expanded(
                  child: SizedBox(
                    height: Get.height * 0.06, // Responsive height
                    child: TextField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: Get.width * 0.035, // Responsive font size
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isEmpty) {
                          Get.snackbar(
                            'Empty Search',
                            'Please enter a city name',
                            backgroundColor: Colors.orange.withOpacity(0.8),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            duration: Duration(seconds: 2),
                          );
                          return;
                        }
                        city = value.trim();
                        _fetchWeather();
                      },
                      decoration: InputDecoration(
                        labelText: 'Search City',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: Get.width * 0.032,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.surface,
                          size: Get.width * 0.05,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.03,
                          vertical: Get.height * 0.01,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: Get.width * 0.03),

                // Location Button
                GestureDetector(
                  onTap: () {
                    _getCurrentLocationAndFetchWeather();
                  },
                  child: Container(
                    padding: EdgeInsets.all(Get.width * 0.025),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.my_location_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: Get.width * 0.06,
                    ),
                  ),
                ),

                SizedBox(width: Get.width * 0.02),

                // Theme Toggle Button
                GestureDetector(
                  onTap: notifier.toggleTheme,
                  child: Tooltip(
                    message: 'Theme: ${notifier.getThemeName()}',
                    child: Container(
                      padding: EdgeInsets.all(Get.width * 0.025),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        notifier.getThemeIcon(),
                        color: Theme.of(context).colorScheme.secondary,
                        size: Get.width * 0.06,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.02),
                if (isLoading)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/loading.json',
                          width: Get.width * 0.4,
                          height: Get.height * 0.25,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                        const SizedBox(height: 20),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Text(
                                isLocationLoading
                                    ? '📍 Getting your location...'
                                    : '🌤️ Loading weather data...',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else ...[
                  if (currentValue.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$city${country.isNotEmpty ? ', $country' : ''}',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Get.width * 0.08, // Responsive font size
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: Get.height * 0.01),
                        Text(
                          '${currentValue['temp_c']}°C',
                          style: TextStyle(
                            fontSize: Get.width * 0.12, // Responsive font size
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${currentValue['condition']['text']}",
                          style: TextStyle(
                            fontSize: Get.width * 0.045, // Responsive font size
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: Get.height * 0.02),
                        imageWidget,
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Container(
                            height: 100,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary,
                                  offset: Offset(1, 1),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      "https://cdn-icons-png.flaticon.com/512/4148/4148460.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    Text(
                                      "${currentValue['humidity']}%",
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Humidity",
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      "https://cdn-icons-png.flaticon.com/512/2045/2045893.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    Text(
                                      "${currentValue['wind_kph']} kph",
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Wind",
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      "https://cdn-icons-png.flaticon.com/512/6281/6281340.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    Text(
                                      "${hourly.isNotEmpty ? hourly.map((h) => h['temp_c']).reduce((a, b) => a > b ? a : b) : 'N/A'}",
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Max Temp",
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(40),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Today Forecast',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          SlideUpRoute(
                                            page: WeeklyForecast(
                                              currentValue: currentValue,
                                              hourly: hourly,
                                              pastWeek: pastWeek,
                                              next7days: next7days,
                                              city: city,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Weekly Forecast',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 145,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: hourly.length,
                                  itemBuilder: (context, index) {
                                    final hour = hourly[index];
                                    final now = DateTime.now();
                                    final hourTime = DateTime.parse(
                                      hour['time'],
                                    );
                                    final isCurrentHour =
                                        now.hour == hourTime.hour &&
                                        now.day == hourTime.day;
                                    return Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Container(
                                        height: 60,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              isCurrentHour
                                                  ? Colors.orangeAccent
                                                  : Colors.blueGrey,
                                          borderRadius: BorderRadius.circular(
                                            40,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              isCurrentHour
                                                  ? 'Now'
                                                  : formateTime(hour['time']),
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Image.network(
                                              'https:${hour['condition']?['icon']}',
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '${hour['temp_c']} °C',
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
