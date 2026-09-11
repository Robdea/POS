import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/categories_provider.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.categoryId});

  final String? categoryId;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    if (widget.categoryId == null) return;
    final category = await ref
        .read(categoriesRepositoryProvider)
        .getById(widget.categoryId!);
    if (category == null || !mounted) return;
    setState(() {
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(categoriesRepositoryProvider);
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      if (_isEditing) {
        await repo.update(
          id: widget.categoryId!,
          name: _nameController.text.trim(),
          description: description,
        );
      } else {
        await repo.create(
          name: _nameController.text.trim(),
          description: description,
        );
      }
      if (mounted) context.pop(true);
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final loading =
          ref.watch(categoriesProvider).isLoading;
      if (loading) return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar categoría' : 'Nueva categoría'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrorBanner(message: _error!),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Guardar cambios' : 'Crear categoría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}