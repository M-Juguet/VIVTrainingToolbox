
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/program_creator/program_creator_screen.dart';
import '../../features/program_editor/program_editor_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/workspace_setup_screen.dart';
import '../../features/shell/workspace_missing_screen.dart';
import '../../features/shell/main_shell.dart';
import '../storage/workspace_provider.dart';
import '../widgets/update_listener_wrapper.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final wsState = ref.watch(workspaceProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      if (!wsState.isLoaded) return null;

      final isSetupRoute = state.uri.path == '/setup';
      final isMissingRoute = state.uri.path == '/missing';

      // 1. If no workspace and hasn't skipped setup
      if (wsState.workspaces.isEmpty && !wsState.hasSkippedSetup) {
        return isSetupRoute ? null : '/setup';
      }

      // 2. If has active workspace, check if it exists (only if not already on missing route)
      if (wsState.activeWorkspace != null && !isMissingRoute) {
        final exists = await ref.read(workspaceProvider.notifier).checkActiveWorkspaceExists();
        if (!exists) return '/missing';
      }

      // 3. If on setup or missing but shouldn't be
      if (isSetupRoute && (wsState.workspaces.isNotEmpty || wsState.hasSkippedSetup)) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => const WorkspaceSetupScreen(),
      ),
      GoRoute(
        path: '/missing',
        builder: (context, state) => const WorkspaceMissingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return UpdateListenerWrapper(
            child: MainShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => const ProgramCreatorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/edit',
                builder: (context, state) => const ProgramEditorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
