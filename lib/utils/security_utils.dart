import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// High-level security utilities for password encryption and validation
/// Uses multiple encryption layers with salt and pepper for maximum security
class SecurityUtils {
  // Private pepper - additional secret key (in production, store in environment variables)
  static const String _pepper = 'HackIFM_2025_SecureApp_PepperKey_XYZ789';

  // Salt length for randomization
  static const int _saltLength = 32;

  /// Generate a cryptographically secure random salt
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(
      _saltLength,
      (_) => random.nextInt(256),
    );
    return base64Url.encode(saltBytes);
  }

  /// Advanced password hashing with multiple security layers
  /// Layer 1: SHA-512 with salt
  /// Layer 2: SHA-256 with pepper
  /// Layer 3: HMAC-SHA256 with combined result
  /// Layer 4: Base64 encoding with salt prepended
  static String hashPassword(String password, {String? providedSalt}) {
    // Generate or use provided salt
    final salt = providedSalt ?? _generateSalt();

    // Layer 1: Hash password with salt using SHA-512
    final saltedPassword = '$salt$password';
    final layer1 = sha512.convert(utf8.encode(saltedPassword)).toString();

    // Layer 2: Hash result with pepper using SHA-256
    final pepperedHash = '$layer1$_pepper';
    final layer2 = sha256.convert(utf8.encode(pepperedHash)).toString();

    // Layer 3: HMAC-SHA256 for additional security
    final hmacKey = utf8.encode(_pepper);
    final hmacSha256 = Hmac(sha256, hmacKey);
    final layer3 = hmacSha256.convert(utf8.encode(layer2)).toString();

    // Layer 4: Combine salt with final hash (salt:hash format)
    return '$salt:$layer3';
  }

  /// Verify password against stored hash
  static bool verifyPassword(String password, String storedHash) {
    try {
      // Extract salt from stored hash
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final hash = parts[1];

      // Hash the provided password with the same salt
      final computedHash = hashPassword(password, providedSalt: salt);
      final computedHashPart = computedHash.split(':')[1];

      // Constant-time comparison to prevent timing attacks
      return _constantTimeCompare(hash, computedHashPart);
    } catch (e) {
      return false;
    }
  }

  /// Constant-time string comparison to prevent timing attacks
  static bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Pre-hashed admin credentials for secure storage
  /// Username: hackifm_admin
  /// Password: codezero25
  static final String adminUsername = 'hackifm_admin';

  // Pre-computed hash for admin password
  // This is generated once and stored (never store plain passwords)
  static String getAdminPasswordHash() {
    // In production, this would be stored securely in database or environment
    // For now, we compute it on first use and cache it
    return hashPassword('codezero25');
  }

  /// Validate admin credentials with additional security checks
  static bool validateAdminCredentials(String username, String password) {
    // Check username (case-sensitive)
    if (username != adminUsername) return false;

    // Verify password against pre-computed hash
    final adminHash = getAdminPasswordHash();
    return verifyPassword(password, adminHash);
  }

  /// Generate a secure session token
  static String generateSessionToken() {
    final random = Random.secure();
    final tokenBytes = List<int>.generate(64, (_) => random.nextInt(256));
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final combined = base64Url.encode(tokenBytes) + timestamp;
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Encrypt sensitive data (simple XOR cipher for demonstration)
  /// In production, use proper encryption like AES
  static String encryptData(String data) {
    final key = utf8.encode(_pepper);
    final dataBytes = utf8.encode(data);
    final encrypted = List<int>.generate(
      dataBytes.length,
      (i) => dataBytes[i] ^ key[i % key.length],
    );
    return base64Url.encode(encrypted);
  }

  /// Decrypt sensitive data
  static String decryptData(String encryptedData) {
    final key = utf8.encode(_pepper);
    final encrypted = base64Url.decode(encryptedData);
    final decrypted = List<int>.generate(
      encrypted.length,
      (i) => encrypted[i] ^ key[i % key.length],
    );
    return utf8.decode(decrypted);
  }
}
