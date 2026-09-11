import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../providers/products_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _costController = TextEditingController();

  String? _categoryId;
  DateTime? _entryDate;
  DateTime? _expirationDate;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (widget.productId == null) {
      _entryDate = DateTime.now();
      return;
    }
    final product = await ref.read(
      productProvider(widget.productId!).future,
    );
    if (product == null || !mounted) return;
    setState(() {
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _stockController.text = '${product.currentStock}';
      _costController.text = '${product.purchaseCost}';
      _categoryId = product.categoryId;
      _entryDate = product.entryDate;
      _expirationDate = product.expirationDate;
    });
  }

  Future<void> _pickDate({required bool isEntry}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isEntry ? (_entryDate ?? now) : (_expirationDate ?? now.add(const Duration(days: 30))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isEntry) {
        _entryDate = picked;
      } else {
        _expirationDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      setState(() => _error = 'Selecciona una categoría.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(productsRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          id: widget.productId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _categoryId!,
          entryDate: _entryDate ?? DateTime.now(),
          expirationDate: _expirationDate,
          purchaseCost: double.parse(_costController.text.trim()),
        );
      } else {
        await repo.create(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _categoryId!,
          entryDate: _entryDate ?? DateTime.now(),
          expirationDate: _expirationDate,
          currentStock: int.tryParse(_stockController.text.trim()) ?? 0,
          purchaseCost: double.tryParse(_costController.text.trim()) ?? 0,
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
    _stockController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final productAsync = ref.watch(productProvider(widget.productId!));
      if (productAsync.isLoading) return const Scaffold(body: LoadingWidget());
      if (productAsync.hasError) {
        return Scaffold(
          body: AppErrorWidget(message: '${productAsync.error}'),
        );
      }
    }

    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    final isSaving = _saving || categoriesAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
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
                  prefixIcon: Icon(Icons.inventory_2_outlined),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoría *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final c in categories)
                    DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isEntry: true),
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        _entryDate == null
                            ? 'Fecha ingreso'
                            : DateHelpers.formatDate(_entryDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isEntry: false),
                      icon: const Icon(Icons.event_busy_outlined),
                      label: Text(
                        _expirationDate == null
                            ? 'Caducidad'
                            : DateHelpers.formatDate(_expirationDate!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      enabled: !_isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Stock inicial',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Costo adquisición',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa el costo';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Costo inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrorBanner(message: _error!),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Guardar cambios' : 'Crear producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}