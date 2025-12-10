class InternationalDestination {
  final String countryId;
  final String countryName;

  InternationalDestination({
    required this.countryId,
    required this.countryName,
  });

  factory InternationalDestination.fromJson(Map<String, dynamic> json) {
    return InternationalDestination(
      countryId: json['country_id'] ?? '',
      countryName: json['country_name'] ?? '',
    );
  }
}
