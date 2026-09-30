import 'package:flutter/material.dart';

import '../../design/generated/app_spacing.dart';
import '../../ui/ui.dart';

/// Perfil → Segurança: troca de senha (senha atual, nova e confirmação, cada
/// campo com o olho de revelar). Autenticação é simulada no protótipo: a senha
/// atual não é conferida contra nenhum backend.
class PerfilSegurancaPage extends StatefulWidget {
  const PerfilSegurancaPage({super.key});

  @override
  State<PerfilSegurancaPage> createState() => _PerfilSegurancaPageState();
}

class _PerfilSegurancaPageState extends State<PerfilSegurancaPage> {
  static const _minimo = 6;

  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _confirmar = TextEditingController();
  bool _tentou = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_atual, _nova, _confirmar]) {
      c.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _atual.dispose();
    _nova.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _algoDigitado =>
      _atual.text.isNotEmpty ||
      _nova.text.isNotEmpty ||
      _confirmar.text.isNotEmpty;

  bool get _preenchido =>
      _atual.text.isNotEmpty &&
      _nova.text.isNotEmpty &&
      _confirmar.text.isNotEmpty;

  String? get _erroAtual =>
      _tentou && _atual.text.isEmpty ? 'Informe a senha atual.' : null;

  String? get _erroNova {
    if (!_tentou) return null;
    if (_nova.text.length < _minimo) {
      return 'A nova senha precisa ter ao menos $_minimo caracteres.';
    }
    if (_nova.text == _atual.text) {
      return 'A nova senha deve ser diferente da atual.';
    }
    return null;
  }

  String? get _erroConfirmar => _tentou && _confirmar.text != _nova.text
      ? 'A confirmação não confere com a nova senha.'
      : null;

  void _alterar() {
    setState(() => _tentou = true);
    if (_erroAtual != null || _erroNova != null || _erroConfirmar != null) {
      return;
    }
    _atual.clear();
    _nova.clear();
    _confirmar.clear();
    setState(() => _tentou = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Senha alterada.')));
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Segurança',
      hasUnsavedChanges: _algoDigitado,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'Senha atual',
            required: true,
            error: _erroAtual,
            child: AppTextInput(
              controller: _atual,
              obscureText: true,
              invalid: _erroAtual != null,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'Nova senha',
            required: true,
            error: _erroNova,
            hint: 'Mínimo 6 caracteres, diferente da senha atual.',
            child: AppTextInput(
              controller: _nova,
              obscureText: true,
              invalid: _erroNova != null,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'Confirmar nova senha',
            required: true,
            error: _erroConfirmar,
            child: AppTextInput(
              controller: _confirmar,
              obscureText: true,
              invalid: _erroConfirmar != null,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _alterar(),
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            fullWidth: true,
            onPressed: _preenchido ? _alterar : null,
            child: const Text('Alterar senha'),
          ),
        ],
      ),
    );
  }
}
