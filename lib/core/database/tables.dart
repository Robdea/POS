class Tables {
  Tables._();

  static const String users = 'users';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String auditLogs = 'audit_logs';

  static const String createUsers = '''
    CREATE TABLE $users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      role TEXT NOT NULL CHECK(role IN ('Empleado', 'Jefe')),
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      pending_sync INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String createCategories = '''
    CREATE TABLE $categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      pending_sync INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String createProducts = '''
    CREATE TABLE $products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      category_id TEXT NOT NULL,
      entry_date INTEGER NOT NULL,
      expiration_date INTEGER,
      current_stock INTEGER NOT NULL DEFAULT 0,
      purchase_cost REAL NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      pending_sync INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (category_id) REFERENCES $categories(id)
    )
  ''';

  static const String createAuditLogs = '''
    CREATE TABLE $auditLogs (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      user_name TEXT NOT NULL,
      action TEXT NOT NULL,
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL,
      description TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      pending_sync INTEGER NOT NULL DEFAULT 1
    )
  ''';
}
