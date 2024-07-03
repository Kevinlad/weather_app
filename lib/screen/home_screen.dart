import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool showSuggestions = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            setState(() {
              showSuggestions = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // search bar for city search
                _buildSearchWidget(context),

                // load history of the search
                Consumer<WeatherProvider>(
                  builder: (context, weatherProvider, child) {
                    if (showSuggestions &&
                        weatherProvider.lastSearchedCities.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 86.0),
                        child: Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: weatherProvider.lastSearchedCities
                                .map((city) => GestureDetector(
                                      onTap: () {
                                        _searchController.text = city;
                                        weatherProvider.getWeatherData(city);
                                        setState(() {
                                          showSuggestions = false;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            city,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          const Icon(Icons.arrow_forward_sharp)
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                const SizedBox(height: 20),
                // the details of the weather of search city and loadding circular indicator
                Consumer<WeatherProvider>(
                  builder: (context, weatherProvider, child) {
                    if (weatherProvider.inProgress) {
                      return const CircularProgressIndicator();
                    } else {
                      return Expanded(
                        child: SingleChildScrollView(
                          child: _buildWeatherWidget(weatherProvider),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            controller: _searchController,
            onTap: () {
              setState(() {
                showSuggestions = true;
              });
            },
            onSubmitted: (value) {
              Provider.of<WeatherProvider>(context, listen: false)
                  .getWeatherData(value);
              setState(() {
                showSuggestions = false;
              });
            },
            hintText: "Search the city",
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Provider.of<WeatherProvider>(context, listen: false)
                .getWeatherData(_searchController.text);
            setState(() {
              showSuggestions = false;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            final location =
                Provider.of<WeatherProvider>(context, listen: false)
                        .response
                        ?.location
                        ?.name ??
                    "";
            Provider.of<WeatherProvider>(context, listen: false)
                .getWeatherData(location);
          },
        ),
      ],
    );
  }

//  main ui of the weather on search the waether.
  Widget _buildWeatherWidget(WeatherProvider weatherProvider) {
    if (weatherProvider.response == null) {
      return Text(weatherProvider.message);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.location_on,
                size: 50,
              ),
              Text(
                weatherProvider.response?.location?.name ?? "",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                weatherProvider.response?.location?.country ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${weatherProvider.response?.current?.tempC.toString() ?? ""} °c",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                (weatherProvider.response?.current?.condition?.text
                        .toString() ??
                    ""),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: 200,
              child: Image.network(
                "https:${weatherProvider.response?.current?.condition?.icon}"
                    .replaceAll("64x64", "128x128"),
                scale: 0.7,
              ),
            ),
          ),
          Card(
            elevation: 4,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget(
                        "Humidity",
                        weatherProvider.response?.current?.humidity
                                ?.toString() ??
                            ""),
                    _dataAndTitleWidget("Wind Speed",
                        "${weatherProvider.response?.current?.windKph?.toString() ?? ""} km/h")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget(
                        "UV",
                        weatherProvider.response?.current?.uv?.toString() ??
                            ""),
                    _dataAndTitleWidget("Percipitation",
                        "${weatherProvider.response?.current?.precipMm?.toString() ?? ""} mm")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget(
                        "Local Time",
                        weatherProvider.response?.location?.localtime
                                ?.split(" ")
                                .last ??
                            ""),
                    _dataAndTitleWidget(
                        "Local Date",
                        weatherProvider.response?.location?.localtime
                                ?.split(" ")
                                .first ??
                            ""),
                  ],
                )
              ],
            ),
          )
        ],
      );
    }
  }

  Widget _dataAndTitleWidget(String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            data,
            style: const TextStyle(
              fontSize: 27,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
