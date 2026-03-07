class DeviceDetailArgs {
  final String deviceId;
  final String deviceName;

  const DeviceDetailArgs({
    required this.deviceId,
    required this.deviceName,
  });
}

class AlarmDetailArgs {
  final String alarmId;

  const AlarmDetailArgs({required this.alarmId});
}

class WorkOrderDetailArgs {
  final String orderId;

  const WorkOrderDetailArgs({required this.orderId});
}
