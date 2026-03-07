import 'session_storage_stub.dart'
    if (dart.library.html) 'session_storage_web.dart'
    if (dart.library.io) 'session_storage_io.dart';

Future<Map<String, dynamic>?> readAuthSession() => readAuthSessionImpl();

Future<void> writeAuthSession(Map<String, dynamic> session) =>
    writeAuthSessionImpl(session);

Future<void> clearAuthSession() => clearAuthSessionImpl();
