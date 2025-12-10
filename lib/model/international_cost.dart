class InternationalCost {
  final String name;
  final String code;
  final String service;
  final String description;
  final String currency;
  final double cost;
  final String etd;
  final String currencyUpdatedAt;
  final double currencyValue;

  InternationalCost({
    required this.name,
    required this.code,
    required this.service,
    required this.description,
    required this.currency,
    required this.cost,
    required this.etd,
    required this.currencyUpdatedAt,
    required this.currencyValue,
  });

  factory InternationalCost.fromJson(Map<String, dynamic> json) {
    return InternationalCost(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      service: json['service'] ?? '',
      description: json['description'] ?? '',
      currency: json['currency'] ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      etd: json['etd'] ?? '',
      currencyUpdatedAt: json['currency_updated_at'] ?? '',
      currencyValue: (json['currency_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
