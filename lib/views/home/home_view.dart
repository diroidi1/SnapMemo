import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di.dart';
import '../../models/memo.dart';
import '../../viewmodels/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) {
        final vm = locator<HomeViewModel>();
        // Defer init to after first build
        Future.microtask(vm.init);
        return vm;
      },
      child: Consumer<HomeViewModel>(
        builder: (context, model, _) => Scaffold(
          appBar: AppBar(
            title: const Text('SnapMemo'),
            actions: [
              IconButton(onPressed: () => Navigator.of(context).pushNamed('/settings'), icon: const Icon(Icons.settings))
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 95,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: model.setQuery,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search memos...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: model.busy
                        ? const Center(child: CircularProgressIndicator())
                        : _MemoGrid(memos: model.filteredMemos, onDelete: model.deleteMemo),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: GestureDetector(
            onTapDown: (_) => _animController.forward(),
            onTapUp: (_) => _animController.reverse(),
            onTapCancel: () => _animController.reverse(),
            onTap: () async {
              final memo = await Navigator.of(context).pushNamed('/camera') as Memo?;
              if (memo != null) {
                // ignore: use_build_context_synchronously
                Provider.of<HomeViewModel>(context, listen: false).addMemo(memo);
              }
            },
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
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoGrid extends StatelessWidget {
  final List<Memo> memos;
  final void Function(String id) onDelete;
  const _MemoGrid({required this.memos, required this.onDelete});

  String _timeLeftText(Memo memo) {
    final d = memo.timeLeft;
    if (d.isNegative) return 'Expired';
    if (d.inDays >= 1) return '${d.inDays} day${d.inDays == 1 ? '' : 's'} left';
    if (d.inHours >= 1) return '${d.inHours} hrs left';
    return '${d.inMinutes} mins left';
  }

  @override
  Widget build(BuildContext context) {
    if (memos.isEmpty) {
      return const Center(child: Text('No memos yet. Tap the camera to add.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).pushNamed('/memo', arguments: memo);
            // Refresh home screen when returning from detail
            if (context.mounted) {
              Provider.of<HomeViewModel>(context, listen: false).refresh();
            }
          },
          onLongPress: () => onDelete(memo.id),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(memo.filePath), fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _timeLeftText(memo),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  right: 8,
                  child: Text(
                    memo.note ?? '',
                    style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
