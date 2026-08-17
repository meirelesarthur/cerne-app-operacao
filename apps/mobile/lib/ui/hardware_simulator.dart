import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'button.dart';
import 'card.dart';
import 'chip.dart';
import 'form_field.dart';
import 'text_input.dart';

enum AppHardwareSimulationKind { devices, scale, rfid, scanner }

class AppHardwareSimulator extends StatefulWidget {
  const AppHardwareSimulator({
    super.key,
    required this.kind,
    required this.onCapture,
    this.value,
    this.error,
    this.manualEntryLabel,
    this.manualEntryPlaceholder,
  });

  final AppHardwareSimulationKind kind;
  final String? value;
  final String? error;
  final String? manualEntryLabel;
  final String? manualEntryPlaceholder;
  final ValueChanged<String> onCapture;

  @override
  State<AppHardwareSimulator> createState() => _AppHardwareSimulatorState();
}

class _AppHardwareSimulatorState extends State<AppHardwareSimulator> {
  bool _devicesFound = false;
  late final TextEditingController _manualController;

  @override
  void initState() {
    super.initState();
    _manualController = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant AppHardwareSimulator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = widget.value ?? '';
    if (_manualController.text != nextValue) {
      _manualController.value = TextEditingValue(
        text: nextValue,
        selection: TextSelection.collapsed(offset: nextValue.length),
      );
    }
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  bool get _ready => widget.value?.isNotEmpty ?? false;

  ({String title, String description, String action, IconData icon})
  get _copy => switch (widget.kind) {
    AppHardwareSimulationKind.devices => (
      title: 'Dispositivos próximos',
      description: 'Busca Bluetooth simulada durante o uso do app.',
      action: 'Buscar dispositivos',
      icon: LucideIcons.bluetooth,
    ),
    AppHardwareSimulationKind.scale => (
      title: 'Leitura da balança',
      description: 'Peso estável simulado do equipamento conectado.',
      action: 'Simular leitura',
      icon: LucideIcons.scale,
    ),
    AppHardwareSimulationKind.rfid => (
      title: 'Identificação por RFID',
      description: 'Aproxime o brinco ou informe o código manualmente.',
      action: 'Simular leitura RFID',
      icon: LucideIcons.radio,
    ),
    AppHardwareSimulationKind.scanner => (
      title: 'Scanner SISBOV',
      description: 'Posicione a identificação na área de enquadramento.',
      action: 'Simular captura',
      icon: LucideIcons.scanLine,
    ),
  };

  String get _captureValue => switch (widget.kind) {
    AppHardwareSimulationKind.devices => 'Balança BT-42 + Leitor RFID CERNE',
    AppHardwareSimulationKind.scale => '482,6 kg',
    AppHardwareSimulationKind.rfid => 'RFID 982 000123456789',
    AppHardwareSimulationKind.scanner => 'SISBOV BR 105 621 784 003',
  };

  void _run() {
    if (_ready) {
      setState(() => _devicesFound = false);
      widget.onCapture('');
      return;
    }
    if (widget.kind == AppHardwareSimulationKind.devices && !_devicesFound) {
      setState(() => _devicesFound = true);
      return;
    }
    widget.onCapture(_captureValue);
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.space12,
                height: AppSpacing.space12,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.amber50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  copy.icon,
                  size: AppSpacing.space5,
                  color: AppColors.amber600,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.space2,
                      runSpacing: AppSpacing.space1,
                      children: [
                        Text(
                          copy.title,
                          style: TextStyle(
                            fontSize: AppTypography.md,
                            fontWeight: AppTypography.weightBold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        const AppChip(
                          tone: AppChipTone.amber,
                          child: Text('Simulação'),
                        ),
                      ],
                    ),
                    Text(
                      copy.description,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.kind == AppHardwareSimulationKind.scanner && !_ready) ...[
            const SizedBox(height: AppSpacing.space4),
            Semantics(
              label: 'Área simulada de enquadramento da câmera',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.space20 + AppSpacing.space12,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.amber50,
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                  border: Border.all(color: AppColors.amber300),
                ),
                child: const Icon(
                  LucideIcons.scanLine,
                  size: AppSpacing.space10,
                  color: AppColors.amber600,
                ),
              ),
            ),
          ],
          if (_devicesFound && !_ready) ...[
            const SizedBox(height: AppSpacing.space4),
            const _FoundDevice(label: 'Balança BT-42'),
            const SizedBox(height: AppSpacing.space2),
            const _FoundDevice(label: 'Leitor RFID CERNE'),
          ],
          if (_ready) ...[
            const SizedBox(height: AppSpacing.space4),
            Semantics(
              liveRegion: true,
              label: 'Captura simulada concluída: ${widget.value}',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: AppColors.brand50,
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                ),
                child: Text(
                  widget.value!,
                  style: const TextStyle(
                    fontSize: AppTypography.md,
                    fontWeight: AppTypography.weightBold,
                    color: AppColors.brand700,
                  ),
                ),
              ),
            ),
          ],
          if (widget.error != null && widget.manualEntryLabel == null) ...[
            const SizedBox(height: AppSpacing.space2),
            Semantics(
              liveRegion: true,
              child: Text(
                widget.error!,
                style: const TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: AppColors.red600,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space4),
          AppButton(
            fullWidth: true,
            variant: _ready
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            leftIcon: Icon(
              _ready ? LucideIcons.rotateCw : copy.icon,
              size: AppSpacing.space4,
            ),
            onPressed: _run,
            child: Text(
              _ready
                  ? 'Reiniciar simulação'
                  : widget.kind == AppHardwareSimulationKind.devices &&
                        _devicesFound
                  ? 'Conectar dispositivos'
                  : copy.action,
            ),
          ),
          if (widget.manualEntryLabel != null) ...[
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                Expanded(child: Divider(color: semantic.borderSubtle)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                  ),
                  child: Text(
                    'ou informe manualmente',
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: semantic.fgMuted,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: semantic.borderSubtle)),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            AppFormField(
              label: widget.manualEntryLabel!,
              required: true,
              error: widget.error,
              child: AppTextInput(
                controller: _manualController,
                placeholder: widget.manualEntryPlaceholder,
                invalid: widget.error != null,
                onChanged: widget.onCapture,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FoundDevice extends StatelessWidget {
  const _FoundDevice({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      constraints: const BoxConstraints(minHeight: AppSpacing.space12),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const AppChip(tone: AppChipTone.blue, child: Text('Encontrado')),
        ],
      ),
    );
  }
}

WidgetbookComponent buildHardwareSimulatorWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'HardwareSimulator',
    useCases: [
      for (final kind in AppHardwareSimulationKind.values)
        WidgetbookUseCase(
          name: kind.name,
          builder: (context) => _HardwareSimulatorUseCase(kind: kind),
        ),
    ],
  );
}

class _HardwareSimulatorUseCase extends StatefulWidget {
  const _HardwareSimulatorUseCase({required this.kind});

  final AppHardwareSimulationKind kind;

  @override
  State<_HardwareSimulatorUseCase> createState() =>
      _HardwareSimulatorUseCaseState();
}

class _HardwareSimulatorUseCaseState extends State<_HardwareSimulatorUseCase> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppSpacing.space20 * 5,
        child: AppHardwareSimulator(
          kind: widget.kind,
          value: _value,
          onCapture: (value) => setState(() => _value = value),
        ),
      ),
    );
  }
}
