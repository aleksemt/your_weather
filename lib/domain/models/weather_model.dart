class WeatherModel {
  WeatherModel({
    required this.temperature,
    required this.city,
    required this.pressure,
  });

  final double temperature;
  final String city;
  final double pressure;

  WeatherModel.fromJson(Map<String, dynamic> json)
      : temperature = json['current']['temp_c'],
        city = json['location']['name'],
        pressure = json['current']['pressure_mb'];
}
