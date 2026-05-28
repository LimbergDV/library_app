import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/book_entity.dart';

/// Formulario reutilizable para crear y editar libros.
/// Incluye selector de imagen obligatorio (requerido por la API).
class BookForm extends StatefulWidget {
  final BookEntity? book;
  final Future<bool> Function({
  required String title,
  required String author,
  required String editorial,
  required int numberOfPages,
  required String backgroundColor,
  File? imageFile,
  }) onSubmit;

  const BookForm({super.key, this.book, required this.onSubmit});

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
  File? _selectedImage;
  bool _isSubmitting = false;
  final _imagePicker = ImagePicker();

  static const List<Map<String, dynamic>> _colorOptions = [
    {'name': 'blue',   'label': 'Azul',    'color': Color(0xFF4A6CF7)},
    {'name': 'purple', 'label': 'Morado',  'color': Color(0xFF805AD5)},
    {'name': 'green',  'label': 'Verde',   'color': Color(0xFF38A169)},
    {'name': 'red',    'label': 'Rojo',    'color': Color(0xFFE53E3E)},
    {'name': 'orange', 'label': 'Naranja', 'color': Color(0xFFDD6B20)},
    {'name': 'teal',   'label': 'Teal',    'color': Color(0xFF319795)},
    {'name': 'pink',   'label': 'Rosa',    'color': Color(0xFFED64A6)},
    {'name': 'gray',   'label': 'Gris',    'color': Color(0xFF718096)},
  ];

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    _titleController    = TextEditingController(text: widget.book?.title ?? '');
    _authorController   = TextEditingController(text: widget.book?.author ?? '');
    _editorialController= TextEditingController(text: widget.book?.editorial ?? '');
    _pagesController    = TextEditingController(
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

  // ── Selector de imagen ────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Quitar imagen', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedImage = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // La imagen es obligatoria al crear
    if (!_isEditing && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes seleccionar una imagen de portada'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await widget.onSubmit(
      title: _titleController.text,
      author: _authorController.text,
      editorial: _editorialController.text,
      numberOfPages: int.parse(_pagesController.text),
      backgroundColor: _selectedColor,
      imageFile: _selectedImage,
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
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────
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
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // ── Selector de imagen ────────────────────────
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedImage == null && !_isEditing
                        ? colorScheme.primary.withOpacity(0.4)
                        : Colors.grey.shade300,
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedImage != null
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Cambiar', style: TextStyle(
                                color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: colorScheme.primary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing
                          ? 'Toca para cambiar la imagen'
                          : 'Toca para agregar imagen *',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (!_isEditing) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Requerida por la API',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (_isEditing && widget.book!.urlImage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Se mantendrá la imagen actual si no cambias',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Campos del formulario ─────────────────────
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.title),
                hintText: 'Ej: El principito',
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'El título es requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _authorController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Autor *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'El autor es requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _editorialController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Editorial *',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'La editorial es requerida' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Número de páginas *',
                prefixIcon: Icon(Icons.auto_stories_outlined),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Debe ser mayor a 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Selector de color ─────────────────────────
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
                  onTap: () => setState(
                          () => _selectedColor = option['name'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: option['color'] as Color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                          color: colorScheme.onSurface, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(
                        color: (option['color'] as Color).withOpacity(0.5),
                        blurRadius: 8, spreadRadius: 2,
                      )]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Botón submit ──────────────────────────────
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
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