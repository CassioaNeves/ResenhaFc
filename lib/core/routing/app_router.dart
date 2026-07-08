import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/cadastro_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/grupos/presentation/criar_grupo_screen.dart';
import '../../features/grupos/presentation/grupo_detalhe_screen.dart';
import '../../features/grupos/presentation/meus_grupos_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final indoParaAuth = state.matchedLocation == '/login' || state.matchedLocation == '/cadastro';
      final indoParaSplash = state.matchedLocation == '/splash';

      if (authState is AuthAutenticado) {
        if (indoParaAuth || indoParaSplash) return '/grupos';
        return null;
      }

      if (authState is AuthNaoAutenticado || authState is AuthErro || authState is AuthFalhaDeConectividade) {
        if (!indoParaAuth) return '/login';
        return null;
      }

      return indoParaSplash ? null : '/splash';
    },
    refreshListenable: _AuthStateListenable(ref),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (context, state) => const CadastroScreen()),
      GoRoute(path: '/grupos', builder: (context, state) => const MeusGruposScreen()),
      GoRoute(path: '/grupos/novo', builder: (context, state) => const CriarGrupoScreen()),
      GoRoute(
        path: '/grupos/:grupoId',
        builder: (context, state) => GrupoDetalheScreen(grupoId: state.pathParameters['grupoId']!),
      ),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
