class ApiConfig {
  static String baseUrl = 'http://localhost:3000/api';

  static String get users => '$baseUrl/users';
  static String get fieldVisitors => '$baseUrl/fieldvisitors';
  static String get managers => '$baseUrl/managers';
  static String get authRegister => '$baseUrl/auth/register';
  static String get authRegisterITSector => '$baseUrl/auth/register/it-sector';
  static String get authLogin => '$baseUrl/auth/login';
  static String get members => '$baseUrl/members';
  static String get products => '$baseUrl/products';
  static String get transactions => '$baseUrl/transactions';
  static String get itSectorImport => '$baseUrl/it-sector/import';
  static String get membersImport => '$baseUrl/members/import';
  static String get auditLogs => '$baseUrl/admin/audit-logs';

  static void setBaseUrl(String url) {
    // Remove trailing slash if present
    if (url.endsWith('/')) {
      baseUrl = url.substring(0, url.length - 1);
    } else {
      baseUrl = url;
    }
  }
}
