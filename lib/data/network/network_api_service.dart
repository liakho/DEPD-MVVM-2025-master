import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:depd_mvvm_2025/data/app_exception.dart';
import 'package:depd_mvvm_2025/data/network/base_api_service.dart';

/// Network service adapted for LOCAL CORS PROXY
/// Default proxy base: http://localhost:3000
/// If your proxy exposes the RajaOngkir endpoints under /api/v1, keep _proxyPrefix = '/api/v1'.
/// If your proxy forwards from root (no prefix), set _proxyPrefix = ''.
class NetworkApiServices implements BaseApiServices {
  static const String _baseUrl = 'http://localhost:3000';
  static const String _proxyPrefix = '/api/v1'; // change to '' if your proxy uses root paths

  String _buildUrl(String endpoint) {
    final e = endpoint.trim();
    final path = '$_proxyPrefix/$e'.replaceAll('//', '/');
    return '$_baseUrl$path';
  }

  @override
  Future<dynamic> getApiResponse(String endpoint) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      _logRequest('GET', uri);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 30));

      return _returnResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout');
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }

  @override
  Future<dynamic> postApiResponse(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      _logRequest('POST', uri, data);

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      return _returnResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout');
    } on FormatException {
      throw FetchDataException('Invalid response format');
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }

  void _logRequest(String method, Uri uri, [dynamic data]) {
    print("== $method REQUEST ==");
    print("URL: $uri");
    if (data != null) print("Body: $data");
    print("");
  }

  void _logResponse(int statusCode, String? contentType, String body) {
    print("== RESPONSE ==");
    print("Status Code: $statusCode");
    print("Content-Type: ${contentType ?? '-'}");
    if (body.isEmpty) {
      print("Body: <empty>");
    } else {
      try {
        final decoded = jsonDecode(body);
        const encoder = JsonEncoder.withIndent('  ');
        print("Body:\n${encoder.convert(decoded)}");
      } catch (_) {
        final preview = body.length > 400 ? '${body.substring(0, 400)}...' : body;
        print("Body: $preview");
      }
    }
    print("");
  }

  dynamic _returnResponse(http.Response response) {
    _logResponse(response.statusCode, response.headers['content-type'], response.body);
    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(response.body);
        } catch (_) {
          throw FetchDataException('Invalid JSON response');
        }
      case 400:
        throw BadRequestException(response.body);
      case 404:
        throw NotFoundException('Not Found: ${response.body}');
      case 500:
        throw ServerErrorException('Server error: ${response.body}');
      default:
        throw FetchDataException('Unexpected status ${response.statusCode}: ${response.body}');
    }
  }
}
