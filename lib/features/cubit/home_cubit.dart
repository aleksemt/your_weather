import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import '../../app/core/enums.dart';
import '../../domain/models/weather_model.dart';
import '../../domain/repositories/weather_repositories.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._weatherRepository) : super(const HomeState());

  final WeatherRepository _weatherRepository;

  Future<void> getWeatherModel({
    required String city,
  }) async {
    emit(const HomeState(status: Status.loading));
    try {
      final weatherModel = await _weatherRepository.getWeatherModel(city: city);
      emit(
        HomeState(
          model: weatherModel,
          status: Status.success,
        ),
      );
    } catch (error) {
      emit(
        HomeState(
          status: Status.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void closeAppUsingSystemPop() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
