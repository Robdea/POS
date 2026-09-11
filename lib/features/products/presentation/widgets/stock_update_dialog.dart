import 'package:flutter/material.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../data/models/product_model.dart';

class StockUpdateDialog extends StatefulWidget {
  const StockUpdateDialog({
    super.key,
    required this.product,
    required this.onSubmit,
  });

  final ProductModel product;
  final Future<void> Function(int newStock) onSubmit;

  @override
  State<StockUpdateDialog> createState() => _StockUpdateDialogState();
}

class _StockUpdateDialogState extends State<StockUpdateDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.text = '${widget.product.currentStock}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final newStock = int.parse(_controller.text.trim());
      await widget.onSubmit(newStock);
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Actualizar stock'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.product.name} — stock actual: ${widget.product.currentStock}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUnfocus,
              decoration: const InputDecoration(
                labelText: 'Nuevo stock',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) {
                final n = int.tryParse(value?.trim() ?? '');
                if (n == null || n < 0) return 'Ingresa un número válido';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              ErrorBanner(message: _error!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}