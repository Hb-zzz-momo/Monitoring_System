part of '../alarm_work_tab.dart';

class AlarmCenterView extends StatefulWidget {
  const AlarmCenterView({super.key});

  @override
  State<AlarmCenterView> createState() => _AlarmCenterViewState();
}

class _AlarmCenterViewState extends State<AlarmCenterView> {
  String _selectedLevel = '全部';
  String _selectedStatus = '进行中';
  String _searchQuery = '';
  PageState _state = PageState.loading;
  List<AlarmModel> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    setState(() => _state = PageState.loading);
    try {
      final alarms = await fetchAlarmModels();
      if (!mounted) return;
      setState(() {
        _alarms = alarms;
        _state = alarms.isEmpty ? PageState.empty : PageState.content;
      });
    } catch (e) {
      debugPrint('AlarmWorkTab._loadAlarms error: $e');
      if (!mounted) return;
      setState(() => _state = PageState.error);
    }
  }

  Future<void> _markAlarmProcessed(String alarmId) async {
    try {
      await updateAlarm(alarmId, {'status': '已处理'});
      await _loadAlarms();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('告警已标记为已处理')),
      );
    } catch (e) {
      debugPrint('AlarmWorkTab._markAlarmProcessed error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新失败，请稍后重试')),
      );
    }
  }

  Future<void> _createWorkOrder(String alarmId) async {
    try {
      final workOrderData = await createWorkOrderFromAlarm(alarmId);
      final workOrderId = workOrderData['id']?.toString() ?? '';
      await _loadAlarms();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('工单已创建: $workOrderId')),
      );
    } catch (e) {
      debugPrint('AlarmWorkTab._createWorkOrder error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('创建工单失败，请稍后重试')),
      );
    }
  }

  Future<void> _showAdvancedFilterDialog() async {
    final level = _selectedLevel;
    final status = _selectedStatus;
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        String tempLevel = level;
        String tempStatus = status;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget buildSection(
              String title,
              List<String> values,
              String selected,
              void Function(String) onSelect,
            ) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: values.map((value) {
                      final isSelected = selected == value;
                      return ChoiceChip(
                        label: Text(value),
                        selected: isSelected,
                        onSelected: (_) => setSheetState(() => onSelect(value)),
                      );
                    }).toList(),
                  ),
                ],
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSection('级别', const ['全部', '提示', '预警', '告警'], tempLevel,
                        (value) => tempLevel = value),
                    const SizedBox(height: 16),
                    buildSection('状态', const ['全部', '进行中', '已处理'], tempStatus,
                        (value) => tempStatus = value),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop({
                            'level': tempLevel,
                            'status': tempStatus,
                          });
                        },
                        child: const Text('应用筛选'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;
    setState(() {
      _selectedLevel = result['level'] ?? _selectedLevel;
      _selectedStatus = result['status'] ?? _selectedStatus;
    });
  }

  List<AlarmModel> get _filteredAlarms {
    return _alarms.where((alarm) {
      if (_selectedLevel != '全部') {
        final expectedLevel = _selectedLevel == '提示'
            ? 'info'
            : (_selectedLevel == '预警' ? 'warning' : 'danger');
        if (alarm.level != expectedLevel) {
          return false;
        }
      }
      if (_selectedStatus != '全部' && alarm.status != _selectedStatus) {
        return false;
      }
      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matched = alarm.id.toLowerCase().contains(query) ||
            alarm.title.toLowerCase().contains(query) ||
            alarm.device.toLowerCase().contains(query) ||
            alarm.component.toLowerCase().contains(query) ||
            alarm.description.toLowerCase().contains(query);
        if (!matched) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      state: _state,
      onRetry: _loadAlarms,
      emptyMessage: '暂无告警',
      child: Column(
        children: [
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '级别:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('全部', null),
                            const SizedBox(width: 8),
                            _buildFilterChip('提示', AppColors.info),
                            const SizedBox(width: 8),
                            _buildFilterChip('预警', AppColors.warning),
                            const SizedBox(width: 8),
                            _buildFilterChip('告警', AppColors.danger),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '状态:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip('进行中'),
                    const SizedBox(width: 8),
                    _buildStatusChip('已处理'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showAdvancedFilterDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _filteredAlarms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无告警',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.subText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAlarms.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alarm = _filteredAlarms[index];
                      return _buildAlarmCard(alarm);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color? color) {
    final isSelected = _selectedLevel == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = label;
        });
      },
      child: StatusChip(
        label: label,
        color: color,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = _selectedStatus == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = label;
        });
      },
      child: StatusChip(
        label: label,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildAlarmCard(AlarmModel alarm) {
    final color = alarm.isDanger ? AppColors.danger : AppColors.warning;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.alarmDetail,
            arguments: AlarmDetailArgs(alarmId: alarm.id),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alarm.device} - ${alarm.component}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (alarm.status == '进行中') ...[
                          OutlinedButton(
                            onPressed: () => _markAlarmProcessed(alarm.id),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              '确认',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _createWorkOrder(alarm.id),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              '创建工单',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    alarm.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.subText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
