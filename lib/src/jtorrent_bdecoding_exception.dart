class BDecodingException implements Exception {
  final String message;

  BDecodingException(this.message);

  @override
  String toString() {
    return "BDecodingException: $message";
  }
}
