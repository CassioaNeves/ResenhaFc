class Usuario {
  const Usuario({
    required this.id,
    required this.nomeCompleto,
    required this.nomeExibicao,
    required this.email,
  });

  final String id;
  final String nomeCompleto;
  final String nomeExibicao;
  final String email;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nomeCompleto: json['nomeCompleto'] as String,
      nomeExibicao: json['nomeExibicao'] as String,
      email: json['email'] as String,
    );
  }
}

class Grupo {
  const Grupo({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.estado,
    required this.tipoFutebol,
    required this.organizadorId,
    required this.publico,
  });

  final String id;
  final String nome;
  final String cidade;
  final String estado;
  final String tipoFutebol;
  final String organizadorId;
  final bool publico;

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cidade: json['cidade'] as String,
      estado: json['estado'] as String,
      tipoFutebol: json['tipoFutebol'] as String,
      organizadorId: json['organizadorId'] as String,
      publico: json['publico'] as bool? ?? false,
    );
  }
}
