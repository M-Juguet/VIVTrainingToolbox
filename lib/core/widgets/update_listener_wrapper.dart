import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/update_provider.dart';
import 'update_modal.dart';

class UpdateListenerWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const UpdateListenerWrapper({super.key, required this.child});

  @override
  ConsumerState<UpdateListenerWrapper> createState() => _UpdateListenerWrapperState();
}

class _UpdateListenerWrapperState extends ConsumerState<UpdateListenerWrapper> {
  @override
  void initState() {
    super.initState();
    // Lancement d'une vérification de mise à jour silencieuse après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateProvider.notifier).checkForUpdates(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UpdateState>(updateProvider, (previous, next) {
      if (next.status == UpdateStatus.available && previous?.status != UpdateStatus.available) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const UpdateModal(),
        );
      }
    });

    return widget.child;
  }
}
