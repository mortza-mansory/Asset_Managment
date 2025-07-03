class UserRules {
  final bool canDeleteGovernment;
  final bool canManageAdmins;
  // ... سایر دسترسی‌ها

  UserRules({
    this.canDeleteGovernment = false,
    this.canManageAdmins = false,
  });
}

class PermissionService {
  UserRules? _rules;

  void updateRulesForRole(String role) {
    if (role == 'A1') {
      _rules = UserRules(canDeleteGovernment: true, canManageAdmins: true);
    } else if (role == 'A2') {
      _rules = UserRules(canDeleteGovernment: false, canManageAdmins: true);
    } else {
      _rules = UserRules();
    }
  }

  bool can(String permissionKey) {
    if (_rules == null) return false;

    switch (permissionKey) {
      case 'delete_company':
        return _rules!.canDeleteGovernment;
      case 'manage_admins':
        return _rules!.canManageAdmins;
    // ... سایر کلیدها
      default:
        return false;
    }
  }

  void clear() {
    _rules = null;
  }
}