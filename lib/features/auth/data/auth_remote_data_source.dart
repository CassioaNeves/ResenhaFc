import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> registrar({
    required String nomeCompleto,
    required String nomeExibicao,
    required String email,
    required String senha,
    required DateTime dataNascimento,
    String? telefone,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'nomeCompleto': nomeCompleto,
        'nomeExibicao': nomeExibicao,
        'email': email,
        'senha': senha,
        'dataNascimento': dataNascimento.toIso8601String().substring(0, 10),
        if (telefone != null) 'telefone': telefone,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
    String? dispositivoId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'senha': senha,
          if (dispositivoId != null) 'dispositivoId': dispositivoId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthCredenciaisInvalidasException();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> obterUsuarioAtual() async {
    final response = await _apiClient.dio.get('/usuarios/me');
    return response.data as Map<String, dynamic>;
  }
}

class AuthCredenciaisInvalidasException implements Exception {
  const AuthCredenciaisInvalidasException();
}
