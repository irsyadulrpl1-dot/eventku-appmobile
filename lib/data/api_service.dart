import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:eventku/models/event.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // GANTI dengan ID jsonblob milikmu!
  static const String eventsUrl =
      'https://jsonblob.com/api/jsonBlob/01a1d29b-6f57-7f26-8341-4ec586a33aff';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('API >> ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('API << ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('API !! ${error.type}');
          handler.next(error);
        },
      ),
    );
  }

  Future<List<Event>> fetchEvents() async {
    final response = await _dio.get(eventsUrl);

    // dio biasanya sudah mengubah JSON menjadi Map, tapi jaga-jaga
    // kalau datang sebagai teks
    final data = response.data is String
        ? jsonDecode(response.data as String)
        : response.data;

    final list = data['events'] as List;
    return list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
  }
}
