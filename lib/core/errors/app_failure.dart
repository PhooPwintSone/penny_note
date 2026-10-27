/// Base class for errors that are safe to show to the user.
///
/// The UI never sees Drift or platform exceptions directly. Repositories and
/// use cases translate them into one of these failures instead.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The user input does not satisfy the domain rules.
final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

/// Reading from or writing to the local database failed.
final class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'Could not access your saved data.']);
}
