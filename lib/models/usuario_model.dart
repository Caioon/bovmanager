class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String cpf;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String docId) {
    return UsuarioModel(
      id: docId,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'email': email, 'cpf': cpf};
  }

  UsuarioModel copyWith({String? nome, String? email, String? cpf}) {
    return UsuarioModel(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
    );
  }
}
