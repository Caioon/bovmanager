import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/models/usuario_model.dart';

AnimalModel makeAnimal({
  String id = 'animal-1',
  String nome = 'Boi Teste',
  String brinco = 'A001',
  String raca = 'Nelore',
  double pesoAtual = 450.0,
  DateTime? dataNascimento,
  String? fotoUrl,
  String propriedadeId = 'prop-1',
}) => AnimalModel(
  id: id,
  nome: nome,
  brinco: brinco,
  raca: raca,
  pesoAtual: pesoAtual,
  dataNascimento: dataNascimento ?? DateTime(2020, 1, 1),
  fotoUrl: fotoUrl,
  propriedadeId: propriedadeId,
);

PastoModel makePasto({
  String id = 'pasto-1',
  String nome = 'Pasto Norte',
  String propriedadeId = 'prop-1',
  double area = 10.0,
  String descricao = '',
  int? limiteAnimais = 50,
}) => PastoModel(
  id: id,
  nome: nome,
  propriedadeId: propriedadeId,
  area: area,
  descricao: descricao,
  limiteAnimais: limiteAnimais,
);

PropriedadeModel makePropriedade({
  String id = 'prop-1',
  String nome = 'Fazenda Teste',
  String proprietarioId = 'user-1',
  DateTime? dataCadastro,
  double? centroLat = -20.0,
  double? centroLng = -49.0,
}) => PropriedadeModel(
  id: id,
  nome: nome,
  proprietarioId: proprietarioId,
  dataCadastro: dataCadastro ?? DateTime(2023, 6, 1),
  centroLat: centroLat,
  centroLng: centroLng,
);

RebanhoModel makeRebanho({
  String id = 'rebanho-1',
  String nome = 'Rebanho A',
  String pastoId = 'pasto-1',
  String propriedadeId = 'prop-1',
  DateTime? dataCadastro,
}) => RebanhoModel(
  id: id,
  nome: nome,
  pastoId: pastoId,
  propriedadeId: propriedadeId,
  dataCadastro: dataCadastro ?? DateTime(2023, 6, 1),
);

TarefaModel makeTarefa({
  String id = 'tarefa-1',
  String titulo = 'Vacinação',
  String descricao = 'Vacinar o rebanho',
  DateTime? dataExecucao,
  StatusTarefa status = StatusTarefa.pendente,
  String propriedadeId = 'prop-1',
  String usuarioId = 'user-1',
  int? horaExecucaoMinutos,
}) => TarefaModel(
  id: id,
  titulo: titulo,
  descricao: descricao,
  dataExecucao: dataExecucao ?? DateTime(2024, 8, 15),
  status: status,
  propriedadeId: propriedadeId,
  usuarioId: usuarioId,
  horaExecucaoMinutos: horaExecucaoMinutos,
);

UsuarioModel makeUsuario({
  String id = 'user-1',
  String nome = 'João da Silva',
  String email = 'joao@teste.com',
  String cpf = '123.456.789-09',
}) => UsuarioModel(id: id, nome: nome, email: email, cpf: cpf);
