import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/api_client_provider.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../data/auth_remote_data_source.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInicial extends AuthState {
  const AuthInicial();
}

class AuthCarregando extends AuthState {
  const AuthCarregando();
}

class AuthAutenticado extends AuthState {
  const AuthAutenticado(this.usuario);
  final Usuario usuario;
}

class AuthNaoAutenticado extends AuthState {
  const AuthNaoAutenticado();
}

class AuthFalhaDeConectividade extends AuthState {
  const AuthFalhaDeConectividade();
}

class AuthErro extends AuthState {
  const AuthErro(this.mensagem);
  final String mensagem;
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    dataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  AuthController({required this.dataSource, required this.tokenStorage})
      : super(const AuthInicial()) {
    verificarSessaoExistente();
  }

  final AuthRemoteDataSource dataSource;
  final SecureTokenStorage tokenStorage;

  Future<void> verificarSessaoExistente() async {
    final token = await tokenStorage.lerAccessToken();
    state = token != null ? const AuthCarregando() : const AuthNaoAutenticado();
    if (token == null) return;

    try {
      final response = await dataSource.obterUsuarioAtual();
      state = AuthAutenticado(Usuario.fromJson(response));
    } on DioException catch (e) {
      final erroDeAutenticacao = e.response?.statusCode == 401 || e.response?.statusCode == 403;
      if (erroDeAutenticacao) {
        await tokenStorage.limpar();
        state = const AuthNaoAutenticado();
        return;
      }
      state = const AuthFalhaDeConectividade();
    } catch (_) {
      state = const AuthNaoAutenticado();
    }
  }

  Future<void> login({required String email, required String senha}) async {
    state = const AuthCarregando();
    try {
      final response = await dataSource.login(email: email, senha: senha);
      await tokenStorage.salvarTokens(
        accessToken: response['accessToken'] as String,
        refreshToken: response['refreshToken'] as String,
      );
      state = AuthAutenticado(Usuario.fromJson(response['usuario'] as Map<String, dynamic>));
    } on AuthCredenciaisInvalidasException {
      state = const AuthErro('E-mail ou senha inválidos.');
    } on DioException {
      state = const AuthErro('Não foi possível conectar ao servidor. Verifique sua conexão.');
    }
  }

  Future<void> registrar({
    required String nomeCompleto,
    required String nomeExibicao,
    required String email,
    required String senha,
    required DateTime dataNascimento,
  }) async {
    state = const AuthCarregando();
    try {
      await dataSource.registrar(
        nomeCompleto: nomeCompleto,
        nomeExibicao: nomeExibicao,
        email: email,
        senha: senha,
        dataNascimento: dataNascimento,
      );
      await login(email: email, senha: senha);
    } on DioException catch (e) {
      state = AuthErro(_extrairMensagemDeErro(e));
    }
  }

  String _extrairMensagemDeErro(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final mensagem = data['message'];
      if (mensagem is List) {
        return mensagem.join('\n');
      }
      return mensagem.toString();
    }
    return 'Não foi possível criar a conta. Tente novamente.';
  }

  Future<void> logout() async {
    await tokenStorage.limpar();
    state = const AuthNaoAutenticado();
  }
}
