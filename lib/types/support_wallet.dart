class SupportWallet {
  final String name;
  final String icon;

  SupportWallet({required this.name, required this.icon});

  factory SupportWallet.fromJson(Map<String, String> json) {
    return SupportWallet(
      name: json['name'] ?? (throw ArgumentError('support wallet name is null')),
      icon: json['icon'] ?? (throw ArgumentError('support wallet icon is null')),
    );
  }
}
