abstract interface class StatisticsPreferences {
  Future<String?> readDisplayCurrency();

  Future<void> saveDisplayCurrency(String currency);
}
