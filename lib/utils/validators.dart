class Validators {

  // Check email format with regex
  static bool isValidEmailFormat(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email.trim());
  }

  // Common fake/test email domains to block
  static bool isSuspiciousDomain(String email) {
    final suspiciousDomains = [
      'mailinator.com',
      'guerrillamail.com',
      'tempmail.com',
      'throwaway.email',
      'fakeinbox.com',
      'sharklasers.com',
      'yopmail.com',
      'trashmail.com',
    ];
    final domain = email.split('@').last.toLowerCase();
    return suspiciousDomains.contains(domain);
  }
}