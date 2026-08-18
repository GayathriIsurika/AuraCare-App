class UserModel {
  final String firstName;
  final String fullName;
  final String profileImageUrl;
  final bool hasNotifications;

  UserModel({
    required this.firstName,
    required this.fullName,
    required this.profileImageUrl,
    this.hasNotifications = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final fullName = (map['fullName'] ?? map['name'] ?? '').toString().trim();
    final firstNameField = (map['firstName'] ?? '').toString().trim();

    final firstName = firstNameField.isNotEmpty
        ? firstNameField
        : (fullName.isNotEmpty ? fullName.split(' ').first : '');

    return UserModel(
      firstName: firstName,
      fullName: fullName,
      profileImageUrl: (map['profileImageUrl'] ?? '').toString(),
      hasNotifications: map['hasNotifications'] ?? false,
    );
  }

  String get initials {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'hasNotifications': hasNotifications,
    };
  }
}
