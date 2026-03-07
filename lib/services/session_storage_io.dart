import 'dart:convert';
import 'dart:io';

const String _kAuthFileName = '.monitoring_system_auth_session.json';

File _sessionFile() {
  final env = Platform.environment;
  final home = env['USERPROFILE'] ?? env['HOME'] ?? Directory.current.path;
  return File('$home${Platform.pathSeparator}$_kAuthFileName');
}

Future<Map<String, dynamic>?> readAuthSessionImpl() async {
  final file = _sessionFile();
  if (!await file.exists()) {
    return null;
  }
  try {
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {}
  return null;
}

Future<void> writeAuthSessionImpl(Map<String, dynamic> session) async {
  final file = _sessionFile();
  await file.writeAsString(jsonEncode(session), flush: true);
}

Future<void> clearAuthSessionImpl() async {
  final file = _sessionFile();
  if (await file.exists()) {
    await file.delete();
  }
}
