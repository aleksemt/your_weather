import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/core/enums.dart';
import '../../data/remote_data_sources/weather_remote_data_source.dart';
import '../../domain/models/weather_model.dart';
import '../../domain/repositories/weather_repositories.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        WeatherRepository(WeatherRemoteDataSource()),
      ),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.status == Status.error) {
            final errorMessage = state.errorMessage ?? 'Unkown error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final weatherModel = state.model;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Twoja pogoda'),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.read<HomeCubit>().closeAppUsingSystemPop();
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      SystemNavigator.pop();
                    }
                  },
                )
              ],
            ),
            body: Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bgsky.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Builder(builder: (context) {
                  if (state.status == Status.loading) {
                    return const Text('Ładowanie');
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (weatherModel != null)
                        _DisplayWeatherWidget(
                          weatherModel: weatherModel,
                        ),
                      _SearchWidget(),
                    ],
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DisplayWeatherWidget extends StatelessWidget {
  const _DisplayWeatherWidget({
    Key? key,
    required this.weatherModel,
  }) : super(key: key);

  final WeatherModel weatherModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weatherModel.temperature.toString(),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const Text(
                  '℃',
                  style: TextStyle(fontSize: 25, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              weatherModel.city,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weatherModel.pressure.toString(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text('hPa',
                    style: TextStyle(fontSize: 25, color: Colors.black54)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SearchWidget extends StatelessWidget {
  _SearchWidget({
    Key? key,
  }) : super(key: key);

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 104,
        left: 10,
        right: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                label: Text('Miejscowość'),
                hintText: 'Wrocław',
              ),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              context.read<HomeCubit>().getWeatherModel(city: _controller.text);
            },
            child: const Text('Sprawdź'),
          ),
        ],
      ),
    );
  }
}
