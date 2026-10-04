import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/customers/presentation/customer_detail_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/more_screen.dart';
import '../../features/delivery/presentation/delivery_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/orders/presentation/create_order_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/qayd_promotion/presentation/qayd_landing_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../di/providers.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final settingsAsync = ref.watch(settingsProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: _SettingsRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/splash') return null;

      final settings = settingsAsync.asData?.value;
      if (settings == null) return null;

      final goingOnboarding = loc == '/onboarding';
      if (!settings.onboardingDone && !goingOnboarding) {
        return '/onboarding';
      }
      if (settings.onboardingDone && goingOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (_, __) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/delivery',
                builder: (_, __) => const DeliveryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (_, __) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/orders/new',
        builder: (_, __) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customers',
        builder: (_, state) => CustomersScreen(
          openAdd: state.uri.queryParameters['add'] == '1',
        ),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (_, state) =>
            CustomerDetailScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/products',
        builder: (_, state) => ProductsScreen(
          openAdd: state.uri.queryParameters['add'] == '1',
        ),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/qayd',
        builder: (_, __) => const QaydLandingScreen(),
      ),
    ],
  );
});

class _SettingsRefresh extends ChangeNotifier {
  _SettingsRefresh(this._ref) {
    _ref.listen(settingsProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
