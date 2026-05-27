import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/book_entity.dart';

/// Formulario reutilizable para crear y editar libros.
/// Recibe el libro a editar (null si es nuevo) y un callback onSubmit.
class BookForm extends StatefulWidget {
  final BookEntity? book; // null = crear, non-null = editar
  final Future<bool> Function({
  required String title,
  required String author,
  required String editorial,
  required int numberOfPages,
  required String backgroundColor,
  File? imageFile,
  }) onSubmit;

  const BookForm({
    super.key,
    this.book,
    required this.onSubmit,
  });

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _editorialController;
  late final TextEditingController _pagesController;
  late String _selectedColor;
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> _colorOptions = [
    {'name': 'blue', 'label': 'Azul', 'color': Color(0xFF4A6CF7)},
    {'name': 'purple', 'label': 'Morado', 'color': Color(0xFF805AD5)},
    {'name': 'green', 'label': 'Verde', 'color': Color(0xFF38A169)},
    {'name': 'red', 'label': 'Rojo', 'color': Color(0xFFE53E3E)},
    {'name': 'orange', 'label': 'Naranja', 'color': Color(0xFFDD6B20)},
    {'name': 'teal', 'label': 'Teal', 'color': Color(0xFF319795)},
    {'name': 'pink', 'label': 'Rosa', 'color': Color(0xFFED64A6)},
    {'name': 'gray', 'label': 'Gris', 'color': Color(0xFF718096)},
  ];

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.book?.title ?? '');
    _authorController =
        TextEditingController(text: widget.book?.author ?? '');
    _editorialController =
        TextEditingController(text: widget.book?.editorial ?? '');
    _pagesController = TextEditingController(
      text: widget.book != null ? widget.book!.numberOfPages.toString() : '',
    );
    _selectedColor = widget.book?.backgroundColor ?? 'blue';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _editorialController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await widget.onSubmit(
      title: _titleController.text,
      author: _authorController.text,
      editorial: _editorialController.text,
      numberOfPages: int.parse(_pagesController.text),
      backgroundColor: _selectedColor,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header del formulario
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isEditing ? Icons.edit_note : Icons.add_box_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Editar Libro' : 'Nuevo Libro',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Campo Título
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.title),
                hintText: 'Ej: El principito',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El título es requerido';
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Campo Autor
            TextFormField(
              controller: _authorController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Autor *',
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Ej: Antoine de Saint-Exupéry',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El autor es requerido';
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Campo Editorial
            TextFormField(
              controller: _editorialController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Editorial *',
                prefixIcon: Icon(Icons.business_outlined),
                hintText: 'Ej: Gallimard',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'La editorial es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Campo Páginas
            TextFormField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Número de páginas *',
                prefixIcon: Icon(Icons.auto_stories_outlined),
                hintText: 'Ej: 256',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'El número de páginas es requerido';
                }
                final n = int.tryParse(v);
                if (n == null || n <= 0) {
                  return 'Ingresa un número válido mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Selector de color
            Text(
              'Color de portada',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colorOptions.map((option) {
                final isSelected = _selectedColor == option['name'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColor = option['name'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: option['color'] as Color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                        color: colorScheme.onSurface,
                        width: 3,
                      )
                          : null,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: (option['color'] as Color)
                              .withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            // Botón submit
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(_isEditing ? Icons.save_outlined : Icons.add),
              label: Text(
                _isSubmitting
                    ? 'Guardando...'
                    : _isEditing
                    ? 'Guardar cambios'
                    : 'Crear libro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
