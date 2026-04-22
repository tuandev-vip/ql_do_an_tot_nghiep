class TimeManager {
  static bool useFakeTime = false;
  static DateTime? _fakeTime;

  static DateTime now() {
    if (useFakeTime && _fakeTime != null) {
      return _fakeTime!;
    }
    return DateTime.now();
  }

  static void setFakeTime(DateTime date) {
    _fakeTime = date;
    useFakeTime = true;
  }

  static void stopFaking() {
    useFakeTime = false;
    _fakeTime = null;
  }
}
