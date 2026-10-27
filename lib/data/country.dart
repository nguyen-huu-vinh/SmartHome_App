class Country {
  const Country(this.flag, this.code, this.name);
  final String flag, code, name;

  static const india = Country('🇮🇳', '+91', 'India');

  static const all = [
    Country('🇦🇺', '+61', 'Australia'),
    Country('🇩🇪', '+49', 'Germany'),
    india,
    Country('🇮🇹', '+39', 'Italy'),
    Country('🇷🇺', '+7', 'Russia'),
    Country('🇺🇸', '+1', 'United States'),
  ];

  @override
  bool operator ==(Object other) =>
      other is Country && other.code == code && other.name == name;

  @override
  int get hashCode => Object.hash(code, name);
}
