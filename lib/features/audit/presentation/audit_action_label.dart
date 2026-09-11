String auditActionLabel(String value) {
  switch (value) {
    case 'CREATE_PRODUCT':
      return 'Producto creado';
    case 'UPDATE_PRODUCT':
      return 'Producto actualizado';
    case 'DELETE_PRODUCT':
      return 'Producto eliminado';
    case 'UPDATE_STOCK':
      return 'Stock actualizado';
    case 'CREATE_CATEGORY':
      return 'Categoría creada';
    case 'UPDATE_CATEGORY':
      return 'Categoría actualizada';
    case 'DELETE_CATEGORY':
      return 'Categoría eliminada';
    case 'CREATE_USER':
      return 'Usuario creado';
    case 'UPDATE_USER':
      return 'Usuario actualizado';
    case 'CHANGE_USER_ROLE':
      return 'Rol cambiado';
    case 'LOGIN':
      return 'Inicio de sesión';
    default:
      return value;
  }
}