import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/links.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../models/store_settings.dart';
import '../../state/cart_controller.dart';
import 'account_menu.dart';
import 'product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _categoryId;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StoreSettings?>();
    final categories = context.watch<List<ProductCategory>?>();
    final products = context.watch<List<Product>?>();
    final reviews = context.watch<List<Review>?>();
    final cartCount = context.select<CartController, int>((c) => c.count);
    final currency = settings?.currency ?? '';

    final visible = (products ?? const <Product>[]).where((p) {
      final inCategory =
          _categoryId == null || p.categoryIds.contains(_categoryId);
      final matches = _query.isEmpty ||
          p.displayName.toLowerCase().contains(_query.toLowerCase());
      return inCategory && matches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          if (settings?.logoUrl.isNotEmpty ?? false) ...[
            SizedBox(
                width: 34,
                height: 34,
                child: ClipOval(child: ProductImage(settings!.logoUrl))),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(settings?.storeName ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ]),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () => context.push('/cart'),
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const AccountMenu(),
        ],
      ),
      floatingActionButton: (settings?.phone.isNotEmpty ?? false)
          ? FloatingActionButton(
        backgroundColor: AppColors.whatsapp,
        onPressed: () => openWhatsApp(
            settings!.phone, 'Hello, ${settings.storeName}!'),
        child: const Icon(Icons.chat, color: Colors.white),
      )
          : null,
      body: LayoutBuilder(builder: (context, box) {
        final side = EdgeInsets.symmetric(horizontal: sidePad(box.maxWidth));
        return CustomScrollView(slivers: [
          if (settings != null) ...[
            SliverPadding(
              padding: side.copyWith(top: 16),
              sliver: SliverToBoxAdapter(child: _Hero(settings: settings)),
            ),
            if (settings.aboutPoints.isNotEmpty || settings.aboutTitle.isNotEmpty)
              SliverPadding(
                padding: side.copyWith(top: 24),
                sliver: SliverToBoxAdapter(child: _About(settings: settings)),
              ),
          ],
          SliverPadding(
            padding: side.copyWith(top: 24),
            sliver: SliverToBoxAdapter(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Shop by category',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (categories != null)
                  SizedBox(
                    height: 108,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      _CategoryTile(
                        label: 'All',
                        imageUrl: '',
                        selected: _categoryId == null,
                        onTap: () => setState(() => _categoryId = null),
                      ),
                      for (final c in categories.where((c) => c.active))
                        _CategoryTile(
                          label: c.name,
                          imageUrl: c.imageUrl,
                          selected: _categoryId == c.id,
                          onTap: () => setState(() => _categoryId = c.id),
                        ),
                    ]),
                  ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: const InputDecoration(
                      hintText: 'Search products', prefixIcon: Icon(Icons.search)),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          if (products == null)
            const SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator())))
          else if (visible.isEmpty)
            const SliverToBoxAdapter(child: CenteredMessage('No products found.'))
          else
            SliverPadding(
              padding: side,
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 230,
                  childAspectRatio: 0.66,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (_, i) => ProductCard(product: visible[i], currency: currency),
                  childCount: visible.length,
                ),
              ),
            ),
          if (reviews != null && reviews.isNotEmpty)
            SliverPadding(
              padding: side.copyWith(top: 32),
              sliver: SliverToBoxAdapter(child: _Reviews(reviews: reviews)),
            ),
          if (settings != null)
            SliverPadding(
              padding: side.copyWith(top: 32, bottom: 32),
              sliver: SliverToBoxAdapter(child: _Footer(settings: settings)),
            ),
        ]);
      }),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.settings});
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (settings.bannerUrls.isNotEmpty)
          _BannerCarousel(urls: settings.bannerUrls)
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                  colors: [Color(0xFFB8400A), Color(0xFF3A1200)]),
            ),
            child: Text(settings.storeName,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
        if (settings.tagline.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(settings.tagline, textAlign: TextAlign.center),
          ),
      ]);
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.urls});
  final List<String> urls;
  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients || widget.urls.length < 2) return;
      _controller.animateToPage((_index + 1) % widget.urls.length,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    AspectRatio(
      aspectRatio: 16 / 7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => ProductImage(widget.urls[i]),
        ),
      ),
    ),
    if (widget.urls.length > 1)
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < widget.urls.length; i++)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _index ? AppColors.accent : Colors.white24,
              ),
            ),
        ]),
      ),
  ]);
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(
      {required this.label,
        required this.imageUrl,
        required this.selected,
        required this.onTap});
  final String label, imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      width: 84,
      margin: const EdgeInsets.only(right: 12),
      child: Column(children: [
        Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: selected ? AppColors.accent : Colors.white24, width: 2),
          ),
          child: ClipOval(
            child: imageUrl.isEmpty
                ? const ColoredBox(
                color: AppColors.card,
                child: Center(child: Icon(Icons.apps, color: AppColors.accent)))
                : ProductImage(imageUrl),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ]),
    ),
  );
}

class _About extends StatelessWidget {
  const _About({required this.settings});
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ABOUT US', style: Theme.of(context).textTheme.titleLarge),
      if (settings.aboutTitle.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(settings.aboutTitle,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
      const SizedBox(height: 8),
      for (final p in settings.aboutPoints)
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('✔ $p')),
      if (settings.aboutFooter.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(settings.aboutFooter),
      ],
    ]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth > 700 && settings.aboutImageUrl.isNotEmpty;
        final image = AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProductImage(settings.aboutImageUrl)),
        );
        if (settings.aboutImageUrl.isEmpty) return text;
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 4, child: image),
          const SizedBox(width: 20),
          Expanded(flex: 6, child: text),
        ])
            : Column(children: [image, const SizedBox(height: 16), text]);
      }),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.reviews});
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What Our Customers Say',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (final r in reviews)
            Container(
              width: 320,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: ClipOval(
                      child: r.avatarUrl.isEmpty
                          ? ColoredBox(
                          color: AppColors.accent,
                          child: Center(
                              child: Text(
                                  r.name.isEmpty ? '?' : r.name[0].toUpperCase())))
                          : ProductImage(r.avatarUrl),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                Text(r.text),
                const SizedBox(height: 6),
                Text('★' * r.rating, style: const TextStyle(color: Colors.amber)),
              ]),
            ),
        ]),
      ]);
}

class _Footer extends StatelessWidget {
  const _Footer({required this.settings});
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(),
        if (settings.address.isNotEmpty) Text(settings.address),
        if (settings.phone.isNotEmpty) Text('WhatsApp: +${settings.phone}'),
        if (settings.businessHours.isNotEmpty)
          Text('Business hours: ${settings.businessHours}'),
        Wrap(children: [
          if (settings.instagramUrl.isNotEmpty)
            TextButton(
                onPressed: () => OpenUrl(settings.instagramUrl),
                child: const Text('Instagram')),
          if (settings.facebookUrl.isNotEmpty)
            TextButton(
                onPressed: () => OpenUrl(settings.facebookUrl),
                child: const Text('Facebook')),
        ]),
        const SizedBox(height: 8),
        Center(
          child: Text(
              '© ${DateTime.now().year} ${settings.storeName}. All rights reserved.',
              textAlign: TextAlign.center),
        ),
      ]);
}