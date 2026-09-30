import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../state/shell_store.dart';

/// Perfil → Informações pessoais: bloco "Dados pessoais" com foto, nome
/// editável e e-mail de acesso somente leitura (o e-mail é gerido no cadastro
/// WEB). O protótipo só grava o nome em memória, no `shellStore`.
class PerfilDadosPage extends ConsumerStatefulWidget {
  const PerfilDadosPage({super.key});

  @override
  ConsumerState<PerfilDadosPage> createState() => _PerfilDadosPageState();
}

class _PerfilDadosPageState extends ConsumerState<PerfilDadosPage> {
  late final TextEditingController _nome;
  late String _nomeSalvo;

  @override
  void initState() {
    super.initState();
    _nomeSalvo = ref.read(shellStoreProvider).user.name;
    _nome = TextEditingController(text: _nomeSalvo)..addListener(_onChanged);
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _valido => _nome.text.trim().isNotEmpty;
  bool get _alterado => _nome.text.trim() != _nomeSalvo;

  void _descartar() => _nome.text = _nomeSalvo;

  void _salvar() {
    ref.read(shellStoreProvider.notifier).updateUserName(_nome.text);
    setState(() => _nomeSalvo = _nome.text.trim());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dados atualizados.')));
  }

  void _alterarFoto() {
    // Sem câmera/galeria reais no protótipo (Limites do protótipo, CLAUDE.md).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A troca de foto não está disponível no protótipo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final user = ref.watch(shellStoreProvider).user;
    final erroNome = _nome.text.isNotEmpty && !_valido
        ? 'Informe o nome.'
        : null;

    return AppPageScaffold(
      title: 'Informações pessoais',
      hasUnsavedChanges: _alterado,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(child: Text('Dados pessoais')),
          const SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              AppAvatar(
                name: user.name,
                initials: AppAvatar.deriveInitials(_nome.text),
                size: AppAvatarSize.lg,
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton(
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.sm,
                      onPressed: _alterarFoto,
                      child: const Text('Alterar foto'),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      'JPG, PNG, WebP ou GIF — até 5 MB.',
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Nome',
            required: true,
            error: erroNome,
            child: AppTextInput(
              controller: _nome,
              invalid: erroNome != null,
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'E-mail',
            hint: 'O e-mail de acesso não pode ser alterado nesta tela.',
            child: AppTextInput(initialValue: user.email, enabled: false),
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: _alterado ? _descartar : null,
                  child: const Text('Descartar alterações'),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: AppButton(
                  fullWidth: true,
                  onPressed: _alterado && _valido ? _salvar : null,
                  child: const Text('Salvar alterações'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
