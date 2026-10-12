import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators.dart';
import '../../core/widgets.dart';
import '../../data/catalog_repository.dart';
import '../../models/store_settings.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});
  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  final _form = GlobalKey<FormState>();
  late final StoreSettings? _s = context.read<StoreSettings?>();

  late final _name = TextEditingController(text: _s?.storeName);
  late final _tagline = TextEditingController(text: _s?.tagline);
  late final _phone = TextEditingController(text: _s?.phone);
  late final _address = TextEditingController(text: _s?.address);
  late final _hours = TextEditingController(text: _s?.businessHours);
  late final _currency = TextEditingController(text: _s?.currency ?? '₹');
  late final _logo = TextEditingController(text: _s?.logoUrl);
  late final _aboutImage = TextEditingController(text: _s?.aboutImageUrl);
  late final _banners =
  TextEditingController(text: (_s?.bannerUrls ?? []).join('\n'));
  late final _aboutTitle = TextEditingController(text: _s?.aboutTitle);
  late final _aboutPoints =
  TextEditingController(text: (_s?.aboutPoints ?? []).join('\n'));
  late final _aboutFooter = TextEditingController(text: _s?.aboutFooter);
  late final _instagram = TextEditingController(text: _s?.instagramUrl);
  late final _facebook = TextEditingController(text: _s?.facebookUrl);
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _name, _tagline, _phone, _address, _hours, _currency,
      _aboutTitle, _aboutPoints, _aboutFooter, _instagram, _facebook,
      _logo, _aboutImage, _banners,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1, String? Function(String?)? validator, String? helper}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(labelText: label, helperText: helper),
        ),
      );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final repo = context.read<CatalogRepository>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await repo.saveSettings(StoreSettings(
        storeName: _name.text.trim(),
        tagline: _tagline.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        businessHours: _hours.text.trim(),
        currency: _currency.text.trim(),
        logoUrl: _logo.text.trim(),
        aboutImageUrl: _aboutImage.text.trim(),
        bannerUrls: _banners.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        aboutTitle: _aboutTitle.text.trim(),
        aboutFooter: _aboutFooter.text.trim(),
        instagramUrl: _instagram.text.trim(),
        facebookUrl: _facebook.text.trim(),
        aboutPoints: _aboutPoints.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      ));
      messenger.showSnackBar(const SnackBar(content: Text('Settings saved')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: ContentWidth(
      maxWidth: 700,
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _field(_name, 'Store name',
              validator: (v) => Validators.required(v, 'Store name')),
          _field(_tagline, 'Tagline'),
          _field(_phone, 'WhatsApp number',
              helper: 'Country code + number, digits only (e.g. 91XXXXXXXXXX)',
              validator: (v) => RegExp(r'^\d{10,15}$').hasMatch((v ?? '').trim())
                  ? null
                  : 'Digits only, with country code'),
          _field(_address, 'Address'),
          _field(_hours, 'Business hours'),
          _field(_currency, 'Currency symbol',
              validator: (v) => Validators.required(v, 'Currency')),
          _field(_logo, 'Logo URL'),
          _field(_banners, 'Banner image URLs',
              maxLines: 3, helper: 'One per line, shown as a slideshow'),
          _field(_aboutImage, 'About section image URL'),
          _field(_aboutTitle, 'About: heading'),
          _field(_aboutPoints, 'About: bullet points',
              maxLines: 6, helper: 'One point per line'),
          _field(_aboutFooter, 'About: closing line'),
          _field(_instagram, 'Instagram URL'),
          _field(_facebook, 'Facebook URL'),
          FilledButton(
              onPressed: _busy ? null : _save, child: const Text('Save settings')),
          const SizedBox(height: 32),
        ]),
      ),
    ),
  );
}