class SupportWallet {
  final String name;
  final String icon;

  SupportWallet({required this.name, required this.icon});

  factory SupportWallet.fromJson(Map<String, String> json) {
    return SupportWallet(
      name: json['name'] ?? (throw ArgumentError('name is null')),
      icon: json['icon'] ?? (throw ArgumentError('icon is null')),
    );
  }
}
