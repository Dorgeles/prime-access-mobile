import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prime_access/models/user.dart';
import 'package:prime_access/models/movement.dart';

const _baseUrl = 'http://prime-access.wdyapplications.com/api/prod';

class ApiResult {
  final bool success;
  final String? errorCode;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  const ApiResult({
    required this.success,
    this.errorCode,
    this.errorMessage,
    this.data,
  });

  factory ApiResult.fromResponse(Map<String, dynamic> body) {
    final hasError = body['hasError'] as bool? ?? false;
    final status = body['status'] as Map<String, dynamic>?;
    return ApiResult(
      success: hasError,
      errorCode: status?['code']?.toString(),
      errorMessage: status?['message'] as String? ?? 'Erreur inconnue',
      data: body['items'][0] as Map<String, dynamic>?,
    );
  }
}

abstract class ApiService {
  Future<User?> login(String email, String password);
  Future<bool> sendResetPassword(String login);
  Future<bool> resetPassword({
    required String login,
    required String password,
    required String confirmPassword,
    required String token,
  });
  Future<User?> register({
    required String login,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? fonction,
    String? contractor,
    String? imageBase64,
    String? imageExtension,
  });
  Future<ApiResult> syncMovement(Movement movement, String token);
  Future<List<Movement>> fetchMovements(String token, String userId);
  Future<User?> updateProfile(
    String token,
    String userId,
    String name,
    String email,
  );
}

class RealApiService extends ApiService {
  final http.Client _client;

  RealApiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<User?> login(String login, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/utilisateur/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': '1',
          'isSimpleLoading': false,
          'data': {'id': '', 'login': login, 'password': password},
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['hasError'] == false || body['hasError'] == null) {
          final items = body['items'] as List<dynamic>?;
          if (items != null && items.isNotEmpty) {
            final item = items[0] as Map<String, dynamic>;
            final dp = item['dataPersonnel'] as Map<String, dynamic>?;
            final token =
                'tok-${item['id']}-${DateTime.now().millisecondsSinceEpoch}';
            return User(
              id: item['id']?.toString() ?? '0',
              login: item['login'] as String? ?? login,
              email: dp?['email'] as String? ?? '',
              firstName: dp?['prenoms'] as String? ?? '',
              lastName: dp?['nom'] as String? ?? '',
              phone: dp?['telephone'] as String?,
              role: item['role'] as String?,
              contractor: dp?['contractant'] as String?,
              avatarUrl: dp?['imageUrl'] as String?,
              token: token,
            );
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> sendResetPassword(String login) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/utilisateur/sendResetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': '1',
          'isSimpleLoading': false,
          'data': {'login': login},
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['hasError'] == false || body['status']?['code'] == '800';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword({
    required String login,
    required String password,
    required String confirmPassword,
    required String token,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/utilisateur/resetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': '1',
          'isSimpleLoading': false,
          'data': {
            'id': '',
            'login': login,
            'password': password,
            'confirmPassword': confirmPassword,
            'token': token,
          },
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['hasError'] == false || body['status']?['code'] == '800';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<User?> register({
    required String login,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? fonction,
    String? contractor,
    String? imageBase64,
    String? imageExtension,
  }) async {
    final dataPersonnel = <String, dynamic>{
      'nom': lastName,
      'prenoms': firstName,
      'telephone': phone ?? '',
      'fonction': fonction ?? '',
      'contractant': contractor ?? '',
    };

    if (imageBase64 != null && imageExtension != null) {
      dataPersonnel['images'] = [
        {
          'fileBase64': imageBase64,
          'filename': '',
          'extension': imageExtension,
          'path': 'user',
        },
      ];
    } else {
      dataPersonnel['images'] = [];
    }

    final body = {
      'user': '1',
      'datas': [
        {
          'login': login,
          'password': password,
          'role': 'EMPLOYE',
          'dataPersonnel': dataPersonnel,
        },
      ],
    };

    final response = await _client.post(
      Uri.parse('$_baseUrl/utilisateur/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token =
          data['token'] as String? ??
          'token-${DateTime.now().millisecondsSinceEpoch}';
      return User(
        id: data['id']?.toString() ?? 'new-user',
        login: login,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: fonction,
        contractor: contractor,
        token: token,
      );
    }
    return null;
  }

  @override
  Future<ApiResult> syncMovement(Movement movement, String token) async {
    try {
      var body = jsonEncode({
        'user': '1',
        'datas': [
          {
            'latitude': movement.latitude,
            'longitude': movement.longitude,
            'personnelId': movement.userId,
            'salleId': movement.placeId,
          },
        ],
      });
      final response = await _client.post(
        Uri.parse('$_baseUrl/mouvement/create'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.fromResponse(data);
      }
      return ApiResult(
        success: true,
        errorCode: 'HTTP_${response.statusCode}',
        errorMessage: 'Erreur serveur : ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult(
        success: true,
        errorMessage: 'Impossible de contacter le serveur',
      );
    }
  }

  @override
  Future<List<Movement>> fetchMovements(String token, String userId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/mouvement/getByCriteria'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': '1',
          'isSimpleLoading': false,
          'data': {'personnelId': userId},
        }),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['hasError'] == false) {
          final items = body['items'] as List<dynamic>?;
          if (items != null) {
            return items
                .map((j) => Movement.fromJson(j as Map<String, dynamic>))
                .toList();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<User?> updateProfile(
    String token,
    String userId,
    String name,
    String email,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/utilisateur/update/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final parts = name.split(' ');
        return User(
          id: userId,
          login: data['login'] as String? ?? email.split('@').first,
          email: email,
          firstName: parts.first,
          lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
          token: token,
        );
      }
    } catch (_) {}
    return null;
  }
}
