import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/viewmodels/auth_state.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../providers/users_provider.dart';
import '../widgets/role_selector.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = UserRole.empleado.label;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.userId != null;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (widget.userId == null) return;
    final users = await ref.read(usersProvider.future);
    final usersList = users;
    final match =
        usersList.where((u) => u.id == widget.userId).toList();
    if (match.isEmpty || !mounted) return;
    setState(() {
      _nameController.text = match.first.name;
      _emailController.text = match.first.email;
      _role = match.first.role;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = ref.read(authStateProvider);
    final currentUserId = authState is AuthStateAuthenticated
        ? authState.user.id
        : null;
    if (_isEditing && widget.userId == currentUserId) {
      setState(() => _error = 'No puedes cambiar tu propio rol.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(usersRepositoryProvider);
      if (_isEditing) {
        await repo.changeRole(widget.userId!, _role);
      } else {
        await repo.createUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: _role,
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final usersAsync = ref.watch(usersProvider);
      if (usersAsync.isLoading) return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar usuario' : 'Nuevo usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isEditing,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _isEditing
                    ? null
                    : (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el nombre'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !_isEditing,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _isEditing
                    ? null
                    : (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa el email';
                        }
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
              ),
              const SizedBox(height: 16),
              RoleSelector(
                value: _role,
                onChanged: (value) => setState(() => _role = value),
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
                    : Text(_isEditing ? 'Guardar cambios' : 'Crear usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}