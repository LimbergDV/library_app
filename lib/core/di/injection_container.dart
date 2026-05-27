import 'package:library_app/features/auth/data/repositories/auth_repositoy_impl.dart';

import '../../features/books/domain/usecases/create_book_usecase.dart';
import '../../features/books/domain/usecases/delete_book_usecase.dart';
import '../../features/books/domain/usecases/get_book_usecase.dart';
import '../../features/books/domain/usecases/update_book_usecase.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/books/data/datasources/books_remote_datasource.dart';
import '../../features/books/data/repositories/books_repository_impl.dart';
import '../../features/books/presentation/viewmodels/books_viewmodel.dart';

/// Contenedor de inyección de dependencias manual.
class InjectionContainer {
  late final ApiClient _apiClient;

  late final AuthRemoteDatasource _authRemoteDatasource;
  late final AuthRepositoryImpl _authRepository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late AuthViewModel authViewModel;

  late final BooksRemoteDatasource _booksRemoteDatasource;
  late final BooksRepositoryImpl _booksRepository;
  late final GetBooksUseCase _getBooksUseCase;
  late final CreateBookUseCase _createBookUseCase;
  late final UpdateBookUseCase _updateBookUseCase;
  late final DeleteBookUseCase _deleteBookUseCase;
  late BooksViewModel booksViewModel;

  void init() {
    // 1. Red (compartido entre features)
    _apiClient = ApiClient(baseUrl: 'https://api.aleosh.online');

    // 2. DataSources remotos
    _authRemoteDatasource = AuthRemoteDatasource(apiClient: _apiClient);
    _booksRemoteDatasource = BooksRemoteDatasource(apiClient: _apiClient);

    // 3. Repositories
    _authRepository = AuthRepositoryImpl(remoteDatasource: _authRemoteDatasource);
    _booksRepository = BooksRepositoryImpl(remoteDatasource: _booksRemoteDatasource);

    // 4. Use Cases
    _loginUseCase = LoginUseCase(repository: _authRepository);
    _registerUseCase = RegisterUseCase(repository: _authRepository);
    _getBooksUseCase = GetBooksUseCase(repository: _booksRepository);
    _createBookUseCase = CreateBookUseCase(repository: _booksRepository);
    _updateBookUseCase = UpdateBookUseCase(repository: _booksRepository);
    _deleteBookUseCase = DeleteBookUseCase(repository: _booksRepository);

    // 5. ViewModels
    authViewModel = AuthViewModel(
      loginUseCase: _loginUseCase,
      registerUseCase: _registerUseCase,
    );
    booksViewModel = BooksViewModel(
      getBooksUseCase: _getBooksUseCase,
      createBookUseCase: _createBookUseCase,
      updateBookUseCase: _updateBookUseCase,
      deleteBookUseCase: _deleteBookUseCase,
    );
  }
}