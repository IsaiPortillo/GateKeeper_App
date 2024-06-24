class UserManager {
  static Map<String, String> _users = {
    'admin': 'admin', // username: password
  };

  static bool authenticate(String username, String password) {
    return _users[username] == password;
  }

  static bool changePassword(String username, String currentPassword, String newPassword) {
    if (authenticate(username, currentPassword)) {
      _users[username] = newPassword;
      return true;
    }
    return false;
  }
}