/// A failed API call, carrying Laravel's message and any validation errors.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;

  /// Laravel validation errors keyed by field, e.g. `{'code': ['Invalid code']}`.
  final Map<String, List<String>> fieldErrors;

  bool get isUnauthorized => statusCode == 401;

  String? fieldError(String field) => fieldErrors[field]?.firstOrNull;

  /// The most specific message to show: the first validation error, if any.
  String get displayMessage =>
      fieldErrors.values.expand((errors) => errors).firstOrNull ?? message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
