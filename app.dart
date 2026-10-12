import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/auth_service.dart';
import 'data/catalog_repository.dart';
import 'data/order_repository.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'models/review.dart';
import 'models/store_settings.dart';
import 'router.dart';
import 'state/auth_controller.dart';
import 'state/cart_controller.dart';

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services / repositories (the only layer that talks to Firebase)
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<CatalogRepository>(create: (_) => CatalogRepository()),
        Provider<OrderRepository>(create: (_) => OrderRepository()),
        // App state
        ChangeNotifierProvider<AuthController>(
            create: (c) => AuthController(c.read<AuthService>())),
        ChangeNotifierProvider<CartController>(create: (_) => CartController()),
        // Live data from Firestore. `null` means "still loading".
        StreamProvider<StoreSettings?>(
          create: (c) => c.read<CatalogRepository>().settings(),
          initialData: null,
          catchError: (_, __) => null,
        ),
        StreamProvider<List<ProductCategory>?>(
          create: (c) => c.read<CatalogRepository>().categories(),
          initialData: null,
          catchError: (_, __) => <ProductCategory>[],
        ),
        StreamProvider<List<Product>?>(
          create: (c) => c.read<CatalogRepository>().products(),
          initialData: null,
          catchError: (_, __) => <Product>[],
        ),
        StreamProvider<List<Review>?>(
          create: (c) => c.read<CatalogRepository>().reviews(),
          initialData: null,
          catchError: (_, __) => <Review>[],
        ),
      ],
      child: const _RouterApp(),
    );
  }
}

class _RouterApp extends StatefulWidget {
  const _RouterApp();
  @override
  State<_RouterApp> createState() => _RouterAppState();
}

class _RouterAppState extends State<_RouterApp> {
  late final GoRouter _router = buildRouter(context.read<AuthController>());

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StoreSettings?>();
    return MaterialApp.router(
      title: settings?.storeName ?? 'Store',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
    );
  }
}
