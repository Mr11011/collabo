import 'dart:math';

final String _chars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String generateShortId(int length) {
  final Random random = Random();
  return List.generate(
    length,
        (_) => _chars[random.nextInt(_chars.length)],
  ).join();
}