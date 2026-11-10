abstract interface class ExchangeRateRepository {
  /// Returns the value of one unit of each source currency in [target].
  Future<Map<String, double>> fetchRatesTo({
    required Set<String> sources,
    required String target,
  });
}
