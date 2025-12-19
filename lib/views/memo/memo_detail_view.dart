import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di.dart';
import '../../models/memo.dart';
import '../../viewmodels/memo_detail_view_model.dart';
import '../../services/memo_repository.dart';

class MemoDetailView extends StatelessWidget {
  final Memo memo;
  const MemoDetailView({super.key, required this.memo});

  String _timeLeftText(Duration d) {
    if (d.isNegative) return 'Expired';
    if (d.inDays >= 1) return 'Expires in ${d.inDays} day${d.inDays == 1 ? '' : 's'}';
    if (d.inHours >= 1) return 'Expires in ${d.inHours} hr${d.inHours == 1 ? '' : 's'}';
    return 'Expires in ${d.inMinutes} min${d.inMinutes == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemoDetailViewModel>(
      create: (_) => MemoDetailViewModel(locator<MemoRepository>(), memo),
      child: Consumer<MemoDetailViewModel>(
        builder: (context, model, _) => Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
            titleSpacing: 0,
            centerTitle: true,
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(15, 20, 24, 1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0096B4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 18, color: Color(0xFF00A9C8)),
                  const SizedBox(width: 6),
                  Text(
                    _timeLeftText(model.memo.timeLeft),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Image.file(File(model.memo.filePath), fit: BoxFit.cover, width: double.infinity),
              ),
              Container(
                color: Colors.black,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  model.memo.note ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(icon: Icons.share, label: 'Share', color: const Color(0xFF4A4A4A), onTap: model.share),
                    _ActionButton(icon: Icons.download, label: 'Save', color: const Color(0xFF4A4A4A), onTap: model.export),
                    _ActionButton(
                      icon: Icons.autorenew,
                      label: 'Extend',
                      color: const Color(0xFF0096B4),
                      onTap: () async {
                        final choice = await showModalBottomSheet<Duration>(
                          context: context,
                          backgroundColor: const Color.fromRGBO(20, 20, 20, 1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 12),
                                  const Text('Extend expiry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  _ExtendOption(label: '1 Day', duration: const Duration(days: 1)),
                                  _ExtendOption(label: '1 Week', duration: const Duration(days: 7)),
                                  _ExtendOption(label: '1 Month', duration: const Duration(days: 30)),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            );
                          },
                        );
                        if (choice != null) {
                          await model.extendBy(choice);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Extended by ${_labelFor(choice)}')),
                            );
                          }
                        }
                      },
                    ),
                    _ActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: const Color(0xFF8A1D24),
                      onTap: () async {
                        await model.delete();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(220),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

class _ExtendOption extends StatelessWidget {
  final String label;
  final Duration duration;
  const _ExtendOption({required this.label, required this.duration});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: () => Navigator.of(context).pop(duration),
    );
  }
}

String _labelFor(Duration d) {
  if (d.inDays == 1) return '1 day';
  if (d.inDays == 7) return '1 week';
  if (d.inDays >= 30) return '1 month';
  return '${d.inDays} days';
}
