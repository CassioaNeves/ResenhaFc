import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';
import '../application/grupos_providers.dart';

class MeusGruposScreen extends ConsumerWidget {
  const MeusGruposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gruposAsync = ref.watch(meusGruposProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(meusGruposProvider.future),
        child: gruposAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erro, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Icon(Icons.wifi_off, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              const Center(child: Text('Não foi possível carregar seus grupos.')),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(meusGruposProvider),
                  child: const Text('Tentar novamente'),
                ),
              ),
            ],
          ),
          data: (grupos) {
            if (grupos.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.groups_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Você ainda não participa de nenhum grupo.\nCrie o primeiro ou peça um convite pra entrar em um.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: grupos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final grupo = grupos[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.shield_outlined)),
                    title: Text(grupo.nome),
                    subtitle: Text('${grupo.cidade}/${grupo.estado} · ${grupo.tipoFutebol}'),
                    onTap: () => context.push('/grupos/${grupo.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final criou = await context.push<bool>('/grupos/novo');
          if (criou == true) {
            ref.invalidate(meusGruposProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Criar grupo'),
      ),
    );
  }
}
