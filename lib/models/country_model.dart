class CountryCode {
  final String code;
  final String country;
  final String flag;

  CountryCode({
    required this.code,
    required this.country,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CountryCode &&
              runtimeType == other.runtimeType &&
              code == other.code &&
              country == other.country &&
              flag == other.flag;

  @override
  int get hashCode => code.hashCode ^ country.hashCode ^ flag.hashCode;

}
