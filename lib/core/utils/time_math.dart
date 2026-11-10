double calculateExactEarnings(int totalSeconds, double hourlyRate) {
  return totalSeconds / 3600.0 * hourlyRate;
}

double roundCurrency(double value) {
  return (value * 100).roundToDouble() / 100;
}

int workedSeconds({
  required DateTime start,
  required DateTime end,
  required Iterable<({DateTime start, DateTime end})> breaks,
}) {
  final gross = end.difference(start).inSeconds;
  final breakSeconds = breaks.fold<int>(
    0,
    (sum, item) => sum + item.end.difference(item.start).inSeconds,
  );
  return (gross - breakSeconds).clamp(0, 1 << 31);
}
