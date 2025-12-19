import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di.dart';
import '../../services/memo_repository.dart';
import '../../services/settings_repository.dart';
import '../../viewmodels/settings_view_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsViewModel>(
      create: (_) {
        final vm = SettingsViewModel(locator<SettingsRepository>(), locator<MemoRepository>());
        Future.microtask(vm.init);
        return vm;
      },
      child: Consumer<SettingsViewModel>(
        builder: (context, model, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          ),
          body: model.busy
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Auto-Delete Timer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _TtlSegmented(
                      current: model.settings.defaultTtl,
                      onChanged: model.setDefaultTtl,
                    ),
                    const SizedBox(height: 24),
                    const Text('Camera Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _CardRow(
                      title: 'Show Note Input',
                      subtitle: 'Auto-focus keyboard after taking photo',
                      trailing: Switch(value: model.settings.showNoteInput, onChanged: model.toggleShowNote),
                    ),
                    const SizedBox(height: 24),
                    const Text('Storage & Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _CardRow(
                      title: 'Storage Used',
                      trailing: Text(model.storageLabel),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(40, 0, 0, 1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color.fromRGBO(140, 20, 20, 1)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Danger Zone', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          const Text('This action cannot be undone. All photos will be permanently deleted.'),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                            onPressed: () async {
                              await model.deleteAllMemos();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All memos deleted')));
                              }
                            },
                            child: const Text('Delete All Memos Now'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Center(child: Text('SnapMemo v1.0 - Offline Mode', style: TextStyle(color: Colors.white54))),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const _CardRow({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(25, 25, 25, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: const TextStyle(color: Colors.white54)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _TtlSegmented extends StatelessWidget {
  final Duration current;
  final ValueChanged<Duration> onChanged;
  const _TtlSegmented({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <Duration, String>{
      const Duration(hours: 24): '24 Hours',
      const Duration(days: 3): '3 Days',
      const Duration(days: 7): '1 Week',
      const Duration(days: 30): '1 Month',
    };
    final teal = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(25, 25, 25, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.entries.map((e) {
          final selected = e.key.inHours == current.inHours;
          return GestureDetector(
            onTap: () => onChanged(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? teal : const Color.fromRGBO(18, 18, 18, 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Color.fromRGBO(
                            (teal.r * 255).round().clamp(0, 255),
                            (teal.g * 255).round().clamp(0, 255),
                            (teal.b * 255).round().clamp(0, 255),
                            0.35,
                          ),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
                border: Border.all(color: selected ? teal : const Color.fromRGBO(50, 50, 50, 1)),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
