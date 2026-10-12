class Validators {
  static String? required(String ? v, [String label = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? email(String? v) {
    final r = required(v, 'Email');
    if(r != null) return r;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim());
    return ok ? null : 'Enter a valid email address';
  }
  static String? password(String? v) =>
      (v == null || v.length < 8) ? 'Use at least 8 characters' : null;

  static String? phone(String? v) =>
      RegExp(r'^[6-9]\d{9}$').hasMatch((v ?? '').trim())
         ? null
         : 'Enter a valid 10-digit mobile number';

  static String? number(String? v) =>
      double.tryParse((v ?? '').trim()) == null ? 'Entera number' : null;
}