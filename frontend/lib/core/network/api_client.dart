import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_endpoints.dart';

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  static Map<String, String> headers({String? accessToken}) {
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  static Future<http.Response> get(
    String endpoint, {
    String? accessToken,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    return _client.get(
      uri,
      headers: headers(accessToken: accessToken),
    );
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    return _client.post(
      uri,
      headers: headers(accessToken: accessToken),
      body: jsonEncode(body ?? {}),
    );
  }

  static Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    return _client.patch(
      uri,
      headers: headers(accessToken: accessToken),
      body: jsonEncode(body ?? {}),
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    String? accessToken,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    return _client.delete(
      uri,
      headers: headers(accessToken: accessToken),
    );
  }
}