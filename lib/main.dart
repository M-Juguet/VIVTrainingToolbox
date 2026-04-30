import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/viv_theme.dart';
import 'core/theme/viv_shadcn_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('fr_FR', null);

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1280, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const ProviderScope(
      child: VivFormationToolboxApp(),
    ),
  );
}

class VivFormationToolboxApp extends ConsumerWidget {
  const VivFormationToolboxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return ShadApp.router(
      title: 'VIV Formation Toolbox',
      debugShowCheckedModeBanner: false,
      theme: VivShadcnTheme.lightTheme,
      materialThemeBuilder: (context, shadTheme) {
        return VivTheme.lightTheme;
      },
      routerConfig: goRouter,
    );
  }
}
