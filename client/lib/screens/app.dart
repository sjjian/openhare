import 'package:client/models/sessions.dart';
import 'package:client/screens/instances/instance_add.dart';
import 'package:client/screens/instances/instance_tables.dart';
import 'package:client/screens/instances/instance_update.dart';
import 'package:client/screens/page_skeleton.dart';
import 'package:client/screens/settings/settings.dart';
import 'package:client/screens/about/about.dart';
import 'package:client/screens/sessions/sessions.dart';
import 'package:client/services/sessions/session_sql_editor.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class App extends HookConsumerWidget {
  App({super.key});

  final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/sessions',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: "/sessions",
          pageBuilder: (context, state) =>
              const NoTransitionPage<void>(child: SessionsPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage<void>(child: SettingsPage()),
        ),
        // About 页面
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) =>
              const NoTransitionPage<void>(child: AboutPage()),
        ),
        ShellRoute(
            navigatorKey: _shellNavigatorKey,
            pageBuilder:
                (BuildContext context, GoRouterState state, Widget child) {
              return NoTransitionPage<void>(child: child);
            },
            routes: [
              GoRoute(
                path: "/instances",
                redirect: (context, state) {
                  return lastInstancePage;
                },
              ),
              GoRoute(
                path: '/instances/list',
                pageBuilder: (context, state) {
                  lastInstancePage = '/instances/list';
                  return const NoTransitionPage<void>(child: InstancesPage());
                },
              ),
              GoRoute(
                path: '/instances/add',
                pageBuilder: (context, state) {
                  lastInstancePage = '/instances/add';
                  return const NoTransitionPage<void>(child: AddInstancePage());
                },
              ),
              GoRoute(
                path: '/instances/update',
                pageBuilder: (context, state) {
                  lastInstancePage = '/instances/update';
                  return const NoTransitionPage<void>(
                      child: UpdateInstancePage());
                },
              ),
            ]),
      ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        windowManager.addListener(_WindowListener(ref));
      });
      return null;
    }, []);

    final model = ref.watch(systemSettingNotifierProvider);

    return MaterialApp.router(
      title: 'openhare',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: model.theme == "dark"
            ? MaterialTheme.darkScheme()
            : MaterialTheme.lightScheme(),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(model.language),
    );
  }
}

String lastInstancePage = "/instances/list";

class ScaffoldWithNavRail extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavRail({Key? key, required this.child}) : super(key: key);

  @override
  State<ScaffoldWithNavRail> createState() => _ScaffoldWithNavRailState();
}

class _ScaffoldWithNavRailState extends State<ScaffoldWithNavRail> {
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        MoveWindows(
          child: NavigationRail(
            minWidth: navigationRailWidth,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerLow, // navigation color
            useIndicator: true,
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (value) {
              _onItemTapped(value, context);
            },
            extended: extended,
            leading: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: tabbarHeight),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      extended = !extended;
                    });
                  },
                  child: extended
                      ? const Icon(Icons.menu_open, size: kIconSizeSmall)
                      : const Icon(Icons.menu, size: kIconSizeSmall),
                ),
              ],
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.personal_video),
                label: Text(
                  AppLocalizations.of(context)!.sessions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              NavigationRailDestination(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDatabase,
                  color: Theme.of(context).iconTheme.color ?? Colors.black87,
                ),
                label: Center(
                  child: Text(
                    AppLocalizations.of(context)!.db_instance,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings),
                label: Center(
                  child: Text(
                    AppLocalizations.of(context)!.settings,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              // About 页面
              NavigationRailDestination(
                icon: const Icon(Icons.info_outline),
                label: Center(
                  child: Text(
                    AppLocalizations.of(context)!.about,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: widget.child)
      ],
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/sessions')) {
      return 0;
    }
    if (location.startsWith('/instances')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    if (location.startsWith('/about')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == _ScaffoldWithNavRailState._calculateSelectedIndex(context)) {
      return;
    }
    switch (index) {
      case 0:
        GoRouter.of(context).go('/sessions');
      case 1:
        GoRouter.of(context).go('/instances');
      case 2:
        GoRouter.of(context).go('/settings');
      case 3:
        GoRouter.of(context).go('/about');
    }
  }
}

class _WindowListener with WindowListener {
  final WidgetRef ref;

  _WindowListener(this.ref);

  @override
  void onWindowClose() async {
    SessionListModel sessions = ref.read(sessionsServicesProvider);
    for (var session in sessions.sessions) {
      ref
          .read(sessionSQLEditorServiceProvider(session.sessionId).notifier)
          .saveCode();
    }
    await windowManager.destroy();
  }
}
