class BEncodingException implements Exception {
  final String message;

  BEncodingException(this.message);

  @override
  String toString() {
    return "BEncodingException: $message";
  }
}
