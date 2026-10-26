class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// Retorna el primer mensaje de error para un campo específico, si existe.
  String? errorForField(String field) {
    if (fieldErrors.containsKey(field) && fieldErrors[field]!.isNotEmpty) {
      return fieldErrors[field]!.first;
    }
    return null;
  }

  @override
  String toString() {
    if (fieldErrors.isNotEmpty) {
      return '$message: $fieldErrors';
    }
    return message;
  }
}
