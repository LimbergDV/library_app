/// Wrapper genérico para resultados exitosos o fallidos.
/// Evita propagar excepciones entre capas de la arquitectura.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}