/// difference = actualBalance - expectedBalance
class CalculateDifference {
  const CalculateDifference();

  double call({
    required double actualBalance,
    required double expectedBalance,
  }) {
    return actualBalance - expectedBalance;
  }
}
