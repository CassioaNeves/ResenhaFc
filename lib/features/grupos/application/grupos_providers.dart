import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/api_client_provider.dart';
import '../data/grupos_remote_data_source.dart';

final gruposRemoteDataSourceProvider = Provider<GruposRemoteDataSource>((ref) {
  return GruposRemoteDataSource(ref.watch(apiClientProvider));
});

final meusGruposProvider = FutureProvider<List<Grupo>>((ref) async {
  return ref.watch(gruposRemoteDataSourceProvider).listarMeusGrupos();
});

final grupoPorIdProvider = FutureProvider.family<Grupo, String>((ref, grupoId) async {
  return ref.watch(gruposRemoteDataSourceProvider).buscarPorId(grupoId);
});
