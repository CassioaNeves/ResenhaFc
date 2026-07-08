import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/grupos_providers.dart';

class GrupoDetalheScreen extends ConsumerWidget {
  const GrupoDetalheScreen({super.key, required this.grupoId});

  final String grupoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grupoAsync = ref.watch(grupoPorIdProvider(grupoId));

    return Scaffold(
      appBar: AppBar(title: const Text('Grupo')),
      body: grupoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erro, _) => const Center(child: Text('Não foi possível carregar este grupo.')),
        data: (grupo) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(grupo.nome, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text('${grupo.cidade}/${grupo.estado}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.sports_soccer, size: 18),
                  const SizedBox(width: 4),
                  Text(grupo.tipoFutebol),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Partidas, financeiro e estatísticas do grupo entram nas próximas telas.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
