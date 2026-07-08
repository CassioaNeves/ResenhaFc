import 'package:dio/dio.dart';
import '../config/app_environment.dart';
import '../storage/secure_token_storage.dart';

class ApiClient {
  ApiClient({SecureTokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? SecureTokenStorage(),
        _dio = Dio(
          BaseOptions(
            baseUrl: AppEnvironment.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.lerAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isUnauthorized = error.response?.statusCode == 401;
          final isRefreshCall = error.requestOptions.path.contains('/auth/refresh');

          if (isUnauthorized && !isRefreshCall) {
            try {
              await _renovarTokenComLockUnico();
              final novaResposta = await _repetirRequisicao(error.requestOptions);
              return handler.resolve(novaResposta);
            } catch (_) {
              await _tokenStorage.limpar();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final SecureTokenStorage _tokenStorage;
  Future<void>? _refreshEmAndamento;

  Dio get dio => _dio;

  Future<void> _renovarTokenComLockUnico() {
    return _refreshEmAndamento ??= _executarRefresh().whenComplete(() {
      _refreshEmAndamento = null;
    });
  }

  Future<void> _executarRefresh() async {
    final refreshToken = await _tokenStorage.lerRefreshToken();
    if (refreshToken == null) {
      throw StateError('Nenhum refresh token disponível.');
    }

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    await _tokenStorage.salvarTokens(
      accessToken: response.data['accessToken'] as String,
      refreshToken: response.data['refreshToken'] as String,
    );
  }

  Future<Response<dynamic>> _repetirRequisicao(RequestOptions options) async {
    final novoAccessToken = await _tokenStorage.lerAccessToken();
    final novasOptions = Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $novoAccessToken',
      },
    );
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: novasOptions,
    );
  }
}
