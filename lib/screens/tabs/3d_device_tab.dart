import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_args.dart';
import '../../components/common_widgets.dart';
import '../../services/api_service.dart';
import '../../models/alarm_model.dart';
import '../../models/metrics_model.dart';
import '../../models/component_model.dart';
import 'widgets/sic_module_widget.dart';

/// 3D视图 Tab 内容（嵌入 DeviceDetailShell）
class ThreeDDeviceContent extends StatefulWidget {
  final String deviceId;
  final VoidCallback? onViewCharts;

  const ThreeDDeviceContent({
    super.key,
    required this.deviceId,
    this.onViewCharts,
  });

  @override
  State<ThreeDDeviceContent> createState() => _ThreeDDeviceContentState();
}

class _ThreeDDeviceContentState extends State<ThreeDDeviceContent> {
  bool _showDrawer = false;
  ComponentModel? _selectedComponent;
  PageState _state = PageState.loading;
  MetricsModel _metrics = const MetricsModel(
    temperature: 0.0,
    voltage: 0.0,
    current: 0.0,
    power: 0.0,
  );
  List<ComponentModel> _components = [];
  List<AlarmModel> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _state = PageState.loading);
    try {
      final device = await fetchDevice(widget.deviceId);
      final deviceName = device['name']?.toString() ?? '';
      final metrics = await fetchDeviceMetricsModel(deviceId: widget.deviceId);
      final components = await fetchComponentModels(
        deviceId: widget.deviceId,
        deviceName: deviceName,
      );
      final alarms = await fetchAlarmModels(
        deviceId: widget.deviceId,
        deviceName: deviceName,
      );

      if (!mounted) return;
      setState(() {
        _metrics = metrics;
        _components = components;
        _alarms = alarms;
        _state = PageState.content;
      });
    } catch (e) {
      debugPrint('ThreeDDeviceContent._loadData error: $e');
      if (!mounted) return;
      setState(() => _state = PageState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      state: _state,
      onRetry: _loadData,
      emptyMessage: '暂无设备数据',
      child: Stack(
        children: [
        Column(
          children: [
            // 上半区 3D Viewer（约55%）
            Expanded(
              flex: 55,
              child: Container(
                color: const Color(0xFFE8EAED),
                child: Stack(
                  children: [
                    // 3D 功率模块渲染图
                    Center(
                      child: GestureDetector(
                        onTapDown: (details) => _onModuleTap(details, context),
                        child: const SiCModuleWidget(),
                      ),
                    ),
                    // 顶部工具栏
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _buildToolButton(Icons.refresh, '重置'),
                          const SizedBox(width: 8),
                          _buildToolButton(Icons.all_out, '爆炸图'),
                          const SizedBox(width: 8),
                          _buildToolButton(Icons.fullscreen, '全屏'),
                        ],
                      ),
                    ),
                    // 左下角提示
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            const Text('点击模块部件查看详情', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 下半区 KPI + 告警（约45%）
            Expanded(
              flex: 45,
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Row 1: 温度、电压
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard('温度', '${_metrics.temperature}',
                                '℃', AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard('功率', '${_metrics.power}',
                                'kW', AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2: 电流、功率
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard('电流', '${_metrics.current}',
                                'A', AppColors.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard('电压', '${_metrics.voltage}',
                                'V', AppColors.info),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 3: 最近告警卡（整行，最多2条）
                      _buildRecentAlarmsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // 右侧抽屉
        if (_showDrawer && _selectedComponent != null) ...[
          // 半透明背景
          GestureDetector(
            onTap: () => setState(() => _showDrawer = false),
            child: Container(color: Colors.black38),
          ),
          // 抽屉面板
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.75,
            child: _buildDrawer(_selectedComponent!),
          ),
        ],
        ],
      ),
    );
  }

  void _onModuleTap(TapDownDetails details, BuildContext context) {
    final components = _components;
    if (components.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || renderBox.size.width <= 0) {
      return;
    }

    final localX = details.localPosition.dx.clamp(0, renderBox.size.width);
    final ratio = localX / renderBox.size.width;
    final index = (ratio * components.length).floor().clamp(0, components.length - 1);
    final component = components[index];

    setState(() {
      _showDrawer = true;
      _selectedComponent = component;
    });
  }

  void _showTip(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleToolbarAction(String action) async {
    if (action == '重置') {
      setState(() {
        _showDrawer = false;
        _selectedComponent = null;
      });
      await _loadData();
      _showTip('视图已重置并刷新数据');
      return;
    }
    _showTip('$action 功能已触发，后续可接入真实 3D 引擎动作');
  }

  Future<void> _createWorkOrderFromComponent(ComponentModel component) async {
    final componentName = component.name;
    final matched = _alarms.where((alarm) {
      if (alarm.status != '进行中') return false;
      if (componentName.isEmpty) return true;
      return alarm.component == componentName;
    }).toList();

    AlarmModel? targetAlarm;
    if (matched.isNotEmpty) {
      targetAlarm = matched.first;
    } else {
      for (final alarm in _alarms) {
        if (alarm.status == '进行中') {
          targetAlarm = alarm;
          break;
        }
      }
    }

    if (targetAlarm == null) {
      _showTip('当前没有可创建工单的进行中告警');
      return;
    }

    try {
      final created = await createWorkOrderFromAlarm(targetAlarm.id);
      final workOrderId = created['id']?.toString() ?? '';
      _showTip(workOrderId.isEmpty ? '工单创建成功' : '工单已创建: $workOrderId');
    } catch (e) {
      debugPrint('ThreeDDeviceContent._createWorkOrderFromComponent error: $e');
      _showTip('创建工单失败，请稍后重试');
    }
  }

  Widget _buildToolButton(IconData icon, String tooltip) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: () => _handleToolbarAction(tooltip),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String unit, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: AppColors.subText)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit, style: TextStyle(fontSize: 11, color: AppColors.subText)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlarmsCard() {
    final recentAlarms = _alarms.take(2).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                const Text('最近告警',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${recentAlarms.length}条',
                    style: TextStyle(fontSize: 12, color: AppColors.subText)),
              ],
            ),
            const SizedBox(height: 12),
            ...recentAlarms.map((alarm) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.alarmDetail,
                    arguments: AlarmDetailArgs(alarmId: alarm.id),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 32,
                        decoration: BoxDecoration(
                          color: alarm.isDanger
                              ? AppColors.danger
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alarm.title,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${alarm.component} · ${alarm.time}',
                                style: TextStyle(fontSize: 11, color: AppColors.subText)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.subText),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(ComponentModel component) {
    final hi = component.healthIndex;
    final hiPercent = (hi * 100).toInt();
    final hiColor = hi >= 0.8
        ? AppColors.success
        : (hi >= 0.6 ? AppColors.warning : AppColors.danger);

    return Material(
      elevation: 16,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // 标题：部件名 + 健康等级
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(component.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: hiColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('健康度: $hiPercent%',
                                  style: TextStyle(fontSize: 12, color: hiColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showDrawer = false),
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HI 大条形
                    const Text('HI (健康度)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: hi,
                        backgroundColor: AppColors.divider,
                        color: hiColor,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$hiPercent%',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: hiColor)),
                        Text(hi >= 0.8 ? '良好' : (hi >= 0.6 ? '注意' : '警告'),
                            style: TextStyle(fontSize: 12, color: hiColor)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // RUL
                    const Text('RUL (剩余寿命)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${component.rul}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('天', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('预测区间: ${component.rulRange} 天',
                        style: TextStyle(fontSize: 12, color: AppColors.subText)),
                    const SizedBox(height: 24),
                    // 建议动作
                    const Text('建议动作',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...component.suggestions.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    // 相关测点
                    const Text('相关测点',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...component.metrics.map((metric) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(metric.name, style: const TextStyle(fontSize: 13)),
                              Text('${metric.value} ${metric.unit}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _showDrawer = false);
                        widget.onViewCharts?.call();
                      },
                      child: const Text('查看曲线'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _createWorkOrderFromComponent(component),
                      child: const Text('创建工单'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

