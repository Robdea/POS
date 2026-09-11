class AppConstants {
  AppConstants._();

  static const int lowStockThreshold = 10;
  static const int nearExpirationDays = 7;
  static const double largeScreenMinWidth = 600.0;
}

enum UserRole {
  empleado('Empleado'),
  jefe('Jefe');

  const UserRole(this.label);
  final String label;
}

enum AuditAction {
  createProduct('CREATE_PRODUCT'),
  updateProduct('UPDATE_PRODUCT'),
  deleteProduct('DELETE_PRODUCT'),
  updateStock('UPDATE_STOCK'),
  createCategory('CREATE_CATEGORY'),
  updateCategory('UPDATE_CATEGORY'),
  deleteCategory('DELETE_CATEGORY'),
  createUser('CREATE_USER'),
  updateUser('UPDATE_USER'),
  changeUserRole('CHANGE_USER_ROLE'),
  login('LOGIN');

  const AuditAction(this.value);
  final String value;
}

enum ProductStockStatus { sinStock, stockBajo, disponible }

enum ProductExpirationStatus { sinFecha, proximoACaducar, caducado, vigente }
