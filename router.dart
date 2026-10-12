import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/admin/admin_screen.dart';
import 'features/auth/admin_login_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/cart/checkout_screen.dart';
import 'features/cart/order_confirmation_screen.dart';
import 'features/catalog/home_screen.dart';
import 'features/catalog/product_detail_screen.dart';
import 'features/home/landing_screen.dart';
import 'features/orders/orders_screen.dart';
import 'state/auth_controller.dart';

/// Browsing is public. Checkout, orders, welcome and admin require login.
/// Admin additionally requires users/{uid}.role == 'admin'.
GoRouter buildRouter(AuthController auth) {
  const authPaths = {'/login', '/register', '/forgot'};
  bool isProtected(String p) =>
      p == '/checkout' ||
          p == '/orders' ||
          p == LandingScreen.path ||
          p == OrderConfirmationScreen.path ||
          p.startsWith('/admin') && p != AdminLoginScreen.path;
  String safe(String? from) =>
      (from != null && from.startsWith('/')) ? from : '/';

  return GoRouter(
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final from = state.uri.queryParameters['from'];

      if (!auth.initialized) {
        return isProtected(loc)
            ? Uri(path: '/splash', queryParameters: {'from': loc}).toString()
            : null;
      }
      if (loc == '/splash') return safe(from);

      final loggedIn = auth.user != null;
      if (!loggedIn && isProtected(loc)) {
        return Uri(path: '/login', queryParameters: {'from': loc}).toString();
      }
      // After sign-in: go back to where the user was headed (e.g. checkout),
      // otherwise show the landing page.
      if (loggedIn && authPaths.contains(loc)) {
        return from != null ? safe(from) : LandingScreen.path;
      }
      // Already signed in as admin -> skip the admin login form.
      if (loggedIn && loc == AdminLoginScreen.path && auth.isAdmin) {
        return '/admin';
      }
      if (loc.startsWith('/admin') &&
          loc != AdminLoginScreen.path &&
          !auth.isAdmin) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: LandingScreen.path,
        builder: (_, __) => const LandingScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, s) => ProductDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(
        path: OrderConfirmationScreen.path,
        builder: (_, s) => OrderConfirmationScreen(
          args: s.extra is OrderConfirmationArgs
              ? s.extra as OrderConfirmationArgs
              : null,
        ),
      ),
      GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: AdminLoginScreen.path,
        builder: (_, __) => const AdminLoginScreen(),
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
      GoRoute(
        path: '/splash',
        builder: (_, __) =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ],
  );
}