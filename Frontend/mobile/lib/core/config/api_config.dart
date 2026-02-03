class ApiConfig {
  // Base URL - Change this for different environments
  static const String baseUrl = 'http://localhost:8000';

  // Auth endpoints

  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String googleAuth = '$baseUrl/auth/google';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String verifyEmail = '$baseUrl/auth/verify-email';

  // Student endpoints
  static const String studentProfile = '$baseUrl/students/me';
  static const String updateProfile = '$baseUrl/students/me/profile';
  static const String uploadResume = '$baseUrl/students/me/resume';
  static const String uploadProfilePicture =
      '$baseUrl/students/me/profile-picture';
  static const String registerStudent = '$baseUrl/auth/register/student';

  // Enterprise endpoints
  static const String enterpriseProfile = '$baseUrl/enterprises/me';
  static const String updateEnterpriseProfile =
      '$baseUrl/enterprises/me/profile';
  static const String uploadEnterpriseLogo = '$baseUrl/enterprises/me/logo';
  static const String registerEnterprise = '$baseUrl/auth/register/enterprise';

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
