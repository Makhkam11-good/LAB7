String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
      ? null
      : 'Enter a valid email, e.g. name@narxoz.kz.';
}
