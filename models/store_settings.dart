class StoreSettings {
  final String storeName,
      tagline,
      phone,
      address,
      businessHours,
      currency,
      logoUrl,
      aboutImageUrl,
      aboutTitle,
      aboutFooter,
      instagramUrl,
      facebookUrl;
  final List<String> bannerUrls, aboutPoints;

  const StoreSettings({
    required this.storeName,
    required this.tagline,
    required this.phone,
    required this.address,
    required this.businessHours,
    required this.currency,
    required this.logoUrl,
    required this.aboutImageUrl,
    required this.aboutTitle,
    required this.aboutFooter,
    required this.instagramUrl,
    required this.facebookUrl,
    required this.bannerUrls,
    required this.aboutPoints,
  });

  factory StoreSettings.fromMap(Map<String, dynamic> d) => StoreSettings(
    storeName: d['storeName'] ?? '',
    tagline: d['tagline'] ?? '',
    phone: d['phone'] ?? '',
    address: d['address'] ?? '',
    businessHours: d['businessHours'] ?? '',
    currency: d['currency'] ?? '₹',
    logoUrl: d['logoUrl'] ?? '',
    aboutImageUrl: d['aboutImageUrl'] ?? '',
    aboutTitle: d['aboutTitle'] ?? '',
    aboutFooter: d['aboutFooter'] ?? '',
    instagramUrl: d['instagramUrl'] ?? '',
    facebookUrl: d['facebookUrl'] ?? '',
    bannerUrls: List<String>.from(d['bannerUrls'] ?? const []),
    aboutPoints: List<String>.from(d['aboutPoints'] ?? const []),
  );

  Map<String, dynamic> toMap() => {
    'storeName': storeName,
    'tagline': tagline,
    'phone': phone,
    'address': address,
    'businessHours': businessHours,
    'currency': currency,
    'logoUrl': logoUrl,
    'aboutImageUrl': aboutImageUrl,
    'aboutTitle': aboutTitle,
    'aboutFooter': aboutFooter,
    'instagramUrl': instagramUrl,
    'facebookUrl': facebookUrl,
    'bannerUrls': bannerUrls,
    'aboutPoints': aboutPoints,
  };
}