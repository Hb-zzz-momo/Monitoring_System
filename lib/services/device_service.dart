import 'api_service.dart' as api;

class DeviceService {
  Future<List<Map<String, dynamic>>> fetchDevices() {
    return api.fetchDevices();
  }

  Future<Map<String, dynamic>> fetchDevice(String id) {
    return api.fetchDevice(id);
  }

  Future<Map<String, dynamic>> updateDevice(
    String id,
    Map<String, dynamic> fields,
  ) {
    return api.updateDevice(id, fields);
  }

  Future<Map<String, dynamic>> fetchMetrics({String? deviceId}) {
    return api.fetchDeviceMetrics(deviceId: deviceId);
  }
}

final DeviceService deviceService = DeviceService();
