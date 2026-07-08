import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/auth_controller.dart';

class CadastroScreen extends ConsumerStatefulWidget {
  const CadastroScreen({super.key});

  @override
  ConsumerState<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends ConsumerState<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCompletoController = TextEditingController();
  final _nomeExibicaoController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  DateTime? _dataNascimento;

  @override
  void dispose() {
    _nomeCompletoController.dispose();
    _nomeExibicaoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataNascimento() async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year - 20, hoje.month, hoje.day),
      firstDate: DateTime(hoje.year - 100),
      lastDate: hoje,
    );
    if (selecionada != null) {
      setState(() => _dataNascimento = selecionada);
    }
  }

  bool get _idadeValida {
    if (_dataNascimento == null) return false;
    final hoje = DateTime.now();
    var idade = hoje.year - _dataNascimento!.year;
    final aniversarioAindaNaoChegouEsteAno = (hoje.month < _dataNascimento!.month) ||
        (hoje.month == _dataNascimento!.month && hoje.day < _dataNascimento!.day);
    if (aniversarioAindaNaoChegouEsteAno) idade--;
    return idade >= 13;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.length < 8) return 'A senha precisa ter ao menos 8 caracteres';
    final temMinuscula = valor.contains(RegExp('[a-z]'));
    final temMaiuscula = valor.contains(RegExp('[A-Z]'));
    final temNumero = valor.contains(RegExp('[0-9]'));
    if (!temMinuscula || !temMaiuscula || !temNumero) {
      return 'Precisa ter maiúscula, minúscula e número';
    }
    return null;
  }

  void _criarConta() {
    if (!_formKey.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento.')),
      );
      return;
    }
    if (!_idadeValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É necessário ter pelo menos 13 anos para se cadastrar.')),
      );
      return;
    }

    ref.read(authControllerProvider.notifier).registrar(
          nomeCompleto: _nomeCompletoController.text.trim(),
          nomeExibicao: _nomeExibicaoController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text,
          dataNascimento: _dataNascimento!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final carregando = authState is AuthCarregando;

    ref.listen<AuthState>(authControllerProvider, (anterior, atual) {
      if (atual is AuthAutenticado) {
        context.go('/grupos');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeCompletoController,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  validator: (v) => (v == null || v.trim().length < 3) ? 'Informe o nome completo' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
