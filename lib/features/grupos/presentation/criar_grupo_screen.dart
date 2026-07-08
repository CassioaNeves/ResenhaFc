import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../application/grupos_providers.dart';

const _tiposDeFutebolAceitos = ['society', 'campo', 'futsal', 'areia'];

class CriarGrupoScreen extends ConsumerStatefulWidget {
  const CriarGrupoScreen({super.key});

  @override
  ConsumerState<CriarGrupoScreen> createState() => _CriarGrupoScreenState();
}

class _CriarGrupoScreenState extends ConsumerState<CriarGrupoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  String _tipoFutebol = _tiposDeFutebolAceitos.first;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      await ref.read(gruposRemoteDataSourceProvider).criar(
            nome: _nomeController.text.trim(),
            cidade: _cidadeController.text.trim(),
            estado: _estadoController.text.trim().toUpperCase(),
            tipoFutebol: _tipoFutebol,
          );
      if (mounted) context.pop(true);
    } on DioException {
      setState(() => _erro = 'Não foi possível criar o grupo. Verifique os dados e tente novamente.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar grupo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome do grupo', hintText: 'Resenha de Sábado'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome do grupo' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a cidade' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estadoController,
                  decoration: const InputDecoration(labelText: 'Estado (UF)', hintText: 'SP'),
                  maxLength: 2,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                  ],
                  validator: (v) => (v == null || v.trim().length != 2) ? 'Informe a UF (2 letras)' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipoFutebol,
                  decoration: const InputDecoration(labelText: 'Tipo de futebol'),
                  items: _tiposDeFutebolAceitos
                      .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                      .toList(),
                  onChanged: (valor) => setState(() => _tipoFutebol = valor ?? _tiposDeFutebolAceitos.first),
                ),
                const SizedBox(height: 16),
                if (_erro != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _erro!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                FilledButton(
                  onPressed: _enviando ? null : _criar,
                  child: _enviando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Criar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
