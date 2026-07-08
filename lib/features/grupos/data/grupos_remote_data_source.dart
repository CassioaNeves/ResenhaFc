import '../../../core/network/api_client.dart';
import '../../../core/models/models.dart';

class GruposRemoteDataSource {
  GruposRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Grupo>> listarMeusGrupos() async {
    final response = await _apiClient.dio.get('/grupos/meus');
    final lista = response.data as List<dynamic>;
    return lista.map((item) => Grupo.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Grupo> criar({
    required String nome,
    required String cidade,
    required String estado,
    required String tipoFutebol,
    String? descricao,
  }) async {
    final response = await _apiClient.dio.post(
      '/grupos',
      data: {
        'nome': nome,
        'cidade': cidade,
        'estado': estado,
        'tipoFutebol': tipoFutebol,
        if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      },
    );
    return Grupo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Grupo> buscarPorId(String grupoId) async {
    final response = await _apiClient.dio.get('/grupos/$grupoId');
    return Grupo.fromJson(response.data as Map<String, dynamic>);
  }
}
