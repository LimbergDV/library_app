import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/book_entity.dart';
import '../viewmodels/books_viewmodel.dart';
import '../widgets/book_card.dart';
import '../widgets/book_form.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/views/login_view.dart';
import 'book_detail_view.dart';

/// Pantalla principal: lista/grid de libros con CRUD completo.
/// Usa CustomScrollView + SliverAppBar para efecto de scroll enriquecido.
class BooksListView extends StatefulWidget {
  const BooksListView({super.key});

  @override
  State<BooksListView> createState() => _BooksListViewState();
}

class _BooksListViewState extends State<BooksListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Cargar libros al iniciar (después del primer frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksViewModel>().loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // Abrir formulario de creación
  // ─────────────────────────────────────────────────────────
  void _showCreateForm(BuildContext context) {
    final vm = context.read<BooksViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BookForm(
        onSubmit: ({
          required title,
          required author,
          required editorial,
          required numberOfPages,
          required backgroundColor,
          imageFile,
        }) =>
            vm.createBook(
              title: title,
              author: author,
              editorial: editorial,
              numberOfPages: numberOfPages,
              backgroundColor: backgroundColor,
              imageFile: imageFile,
            ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Abrir formulario de edición
  // ─────────────────────────────────────────────────────────
  void _showEditForm(BuildContext context, BookEntity book) {
    final vm = context.read<BooksViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BookForm(
        book: book,
        onSubmit: ({
          required title,
          required author,
          required editorial,
          required numberOfPages,
          required backgroundColor,
          imageFile,
        }) =>
            vm.updateBook(
              id: book.id,
              title: title,
              author: author,
              editorial: editorial,
              numberOfPages: numberOfPages,
              backgroundColor: backgroundColor,
              imageFile: imageFile,
            ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Confirmar y ejecutar eliminación
  // ─────────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, BookEntity book) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_forever_outlined,
                color: colorScheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Deseas eliminar "${book.title}"?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success =
              await context.read<BooksViewModel>().deleteBook(book.id);
              if (mounted && !success) {
                _showError(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context) {
    final vm = context.read<BooksViewModel>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(vm.errorMessage ?? 'Error desconocido'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar con gradiente ──────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Consumer<AuthViewModel>(
                    builder: (_, authVm, __) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${authVm.currentUser?.email.split('@').first ?? 'Usuario'} 👋',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          'Mi Biblioteca',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Toggle grid/lista
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AppBarIconButton(
                        icon: _isGridView
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        onTap: () =>
                            setState(() => _isGridView = !_isGridView),
                      ),
                      const SizedBox(width: 8),
                      _AppBarIconButton(
                        icon: Icons.logout_rounded,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Barra de búsqueda ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar libros...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),

          // ── Contador de resultados ───────────────────────
          Consumer<BooksViewModel>(
            builder: (_, vm, __) {
              final filtered = vm.searchBooks(_searchQuery);
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} libro${filtered.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (vm.isSubmitting) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Contenido principal ──────────────────────────
          Consumer<BooksViewModel>(
            builder: (_, vm, __) {
              // Cargando
              if (vm.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Error
              if (vm.status == BooksStatus.error && vm.books.isEmpty) {
                return SliverFillRemaining(
                  child: _ErrorWidget(
                    message: vm.errorMessage ?? 'Error desconocido',
                    onRetry: () => vm.loadBooks(),
                  ),
                );
              }

              final books = vm.searchBooks(_searchQuery);

              // Sin resultados
              if (books.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyWidget(
                    isSearching: _searchQuery.isNotEmpty,
                    onAdd: () => _showCreateForm(context),
                  ),
                );
              }

              // Grid o Lista
              if (_isGridView) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (ctx, i) => BookCard(
                        book: books[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookDetailView(book: books[i]),
                          ),
                        ),
                        onEdit: () => _showEditForm(context, books[i]),
                        onDelete: () =>
                            _confirmDelete(context, books[i]),
                      ),
                      childCount: books.length,
                    ),
                  ),
                );
              }

              // ListView
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _BookListTile(
                      book: books[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailView(book: books[i]),
                        ),
                      ),
                      onEdit: () => _showEditForm(context, books[i]),
                      onDelete: () => _confirmDelete(context, books[i]),
                    ),
                    childCount: books.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ── FAB para crear libro ───────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo libro'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _BookListTile extends StatelessWidget {
  final BookEntity book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookListTile({
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bookColor = Color(book.backgroundColorValue);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bookColor, Color.lerp(bookColor, Colors.black, 0.3)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.menu_book_rounded,
              color: Colors.white, size: 24),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            Text('${book.numberOfPages} páginas · ${book.editorial}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onAdd;

  const _EmptyWidget({required this.isSearching, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off : Icons.library_books_outlined,
              size: 56,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'Sin resultados' : 'Tu biblioteca está vacía',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Intenta con otro término de búsqueda'
                : 'Agrega tu primer libro con el botón +',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (!isSearching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Agregar libro'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Error de conexión',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
