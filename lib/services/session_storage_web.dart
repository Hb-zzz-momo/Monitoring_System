import 'dart:convert';
import 'dart:html' as html;

const String _kAuthStorageKey = 'monitoring_system.auth.session';

Future<Map<String, dynamic>?> readAuthSessionImpl() async {
  final raw = html.window.localStorage[_kAuthStorageKey];
  if (raw == null || raw.isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {}
  return null;
}

Future<void> writeAuthSessionImpl(Map<String, dynamic> session) async {
  html.window.localStorage[_kAuthStorageKey] = jsonEncode(session);
}

Future<void> clearAuthSessionImpl() async {
  html.window.localStorage.remove(_kAuthStorageKey);
}
