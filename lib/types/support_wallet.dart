class SupportWallet {
  final String name;
  final String icon;

  SupportWallet({required this.name, required this.icon});

  factory SupportWallet.fromJson(Map<String, String> json) {
    return SupportWallet(
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}
