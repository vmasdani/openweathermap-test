// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) => WeatherData()
  ..main = json['main'] == null
      ? null
      : MainData.fromJson(json['main'] as Map<String, dynamic>);

Map<String, dynamic> _$WeatherDataToJson(WeatherData instance) =>
    <String, dynamic>{
      'main': instance.main,
    };

MainData _$MainDataFromJson(Map<String, dynamic> json) =>
    MainData()..temp = (json['temp'] as num?)?.toDouble();

Map<String, dynamic> _$MainDataToJson(MainData instance) => <String, dynamic>{
      'temp': instance.temp,
    };
