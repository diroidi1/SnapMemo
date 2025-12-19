import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/memo_repository.dart';
import '../../services/settings_repository.dart';
import '../../core/di.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();
  XFile? _captured;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  Future<void> _capture() async {
    final xfile = await _picker.pickImage(source: ImageSource.camera);
    if (xfile != null) {
      setState(() => _captured = xfile);
      final settings = await locator<SettingsRepository>().load();
      if (settings.showNoteInput) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          _noteFocus.requestFocus();
        }
      }
    }
  }

  Future<void> _save() async {
    if (_captured == null) return;
    final repo = locator<MemoRepository>();
    final settings = await locator<SettingsRepository>().load();
    final memo = await repo.addMemo(
      imageFile: File(_captured!.path),
      note: _noteController.text.isEmpty ? null : _noteController.text,
      ttl: settings.defaultTtl,
    );
    if (mounted) Navigator.of(context).pop(memo);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    // auto open camera on view enter
    Future.microtask(_capture);
  }

  @override
  void dispose() {
    _animController.dispose();
    _noteController.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.flash_off)),
          if (_captured != null)
            IconButton(
              tooltip: 'Retake',
              onPressed: _capture,
              icon: const Icon(Icons.camera_alt_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: _captured == null
                    ? const Text('No image captured', style: TextStyle(color: Colors.white54))
                    : Image.file(File(_captured!.path), fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                // Reserve space for centered FAB + device inset
                bottom: MediaQuery.of(context).padding.bottom + 88,
              ),
              child: TextField(
                controller: _noteController,
                focusNode: _noteFocus,
                decoration: InputDecoration(
                  hintText: 'Add a quick note (optional)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) => _animController.reverse(),
        onTapCancel: () => _animController.reverse(),
        onTap: _captured == null ? _capture : _save,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0096B4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 150, 180, 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(
              _captured == null ? Icons.camera_alt : Icons.check,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
