import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'main.g.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

@JsonSerializable()
class WeatherData {
  WeatherData();
  MainData? main;

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);
}

@JsonSerializable()
class MainData {
  MainData();
  double? temp;

  factory MainData.fromJson(Map<String, dynamic> json) =>
      _$MainDataFromJson(json);
  Map<String, dynamic> toJson() => _$MainDataToJson(this);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          title: '${dotenv.env['NIM'] ?? ''} - ${dotenv.env['NAMA'] ?? ''}'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _cityName = '';
  WeatherData? _weatherData = null;
  var _loading = false;

  Future<void> fetchWeatherData() async {
    try {
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=${_cityName}&appid=${dotenv.env['OPENWEATHERMAP_KEY']}'));

      if (res.statusCode != HttpStatus.ok) throw res.body;
      setState(() {
        _weatherData = WeatherData.fromJson(jsonDecode(res.body));
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Center(
          child: Column(
            children: [
              ...[
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Focus(
                          child: TextField(
                            controller: (() {
                              final controller = TextEditingController();
                              controller.text = _cityName;

                              return controller;
                            })(),
                            onChanged: (v) {
                              _cityName = v;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Nama kota...',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onFocusChange: (focus) {
                            if (!focus) {
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: MaterialButton(
                          onPressed: () async {
                            setState(() {
                              _loading = true;
                            });
                            fetchWeatherData();
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: const Text('Cari'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
              ...(_weatherData != null
                  ? [
                      Container(
                        margin: EdgeInsets.all(15),
                        child: Text(_cityName.toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      Container(
                        child: const Image(
                            image: AssetImage('assets/weather.png')),
                      ),
                      Column(
                        children: [
                          Container(
                            child: Text(
                              ((_weatherData?.main?.temp ?? 0) - 273.15)
                                  .toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const Text(
                        'Celsius',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )
                    ]
                  : _loading
                      ? [const Text('Loading...')]
                      : [
                          Center(
                            child: Container(
                              child: const Text('No weather data'),
                            ),
                          )
                        ])
            ],
          ),
        ),
      ),
    );
  }
}
