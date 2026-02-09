/// Base failure class for domain-level errors.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Authentication failures (login, signup, token).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Database read/write failures.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Network / API call failures.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Validation failures (invalid input).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// AI service failures.
class AiFailure extends Failure {
  const AiFailure(super.message);
}

/// Export (PDF/CSV) failures.
class ExportFailure extends Failure {
  const ExportFailure(super.message);
}

/// A simple Result type: either a value or a failure.
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
