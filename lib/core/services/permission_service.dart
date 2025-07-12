class UserRules {
  final bool canDeleteGovernment;
  final bool canManageAdmins;
  final bool canManageGovernmentAdmins;
  final bool canManageOperators;

  UserRules({
    this.canDeleteGovernment = false,
    this.canManageAdmins = false,
    this.canManageGovernmentAdmins = false,
    this.canManageOperators = false,
  });
}

class PermissionService {
  UserRules? _rules;

  void updateRulesForRole(String role, {bool canManageGovernmentAdmins = false, bool canManageOperators = false}) {
    if (role == 'A1') {
      _rules = UserRules(canDeleteGovernment: true, canManageAdmins: true, canManageGovernmentAdmins: true, canManageOperators: true);
    } else if (role == 'A2') {
      _rules = UserRules(canDeleteGovernment: false, canManageAdmins: true, canManageGovernmentAdmins: canManageGovernmentAdmins, canManageOperators: canManageOperators);
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
      case 'manage_government_admins':
        return _rules!.canManageGovernmentAdmins;
      case 'manage_operators':
        return _rules!.canManageOperators;
      default:
        return false;
    }
  }

  bool get canManageGovernmentAdmins => _rules?.canManageGovernmentAdmins ?? false;
  bool get canManageOperators => _rules?.canManageOperators ?? false;


  void clear() {
    _rules = null;
  }
}