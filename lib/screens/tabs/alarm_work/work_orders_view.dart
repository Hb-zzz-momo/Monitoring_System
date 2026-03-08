part of '../alarm_work_tab.dart';

class WorkOrdersView extends StatefulWidget {
  const WorkOrdersView({super.key});

  @override
  State<WorkOrdersView> createState() => _WorkOrdersViewState();
}

class _WorkOrdersViewState extends State<WorkOrdersView> {
  String _selectedStatus = '全部';
  String _selectedTime = '近24h';
  String _searchQuery = '';
  PageState _state = PageState.loading;
  List<WorkOrderModel> _workOrders = [];

  @override
  void initState() {
    super.initState();
    _loadWorkOrders();
  }

  Future<void> _loadWorkOrders() async {
    setState(() => _state = PageState.loading);
    try {
      final orders = await fetchWorkOrderModels();
      if (!mounted) return;
      setState(() {
        _workOrders = orders;
        _state = orders.isEmpty ? PageState.empty : PageState.content;
      });
    } catch (e) {
      debugPrint('WorkOrderTab._loadWorkOrders error: $e');
      if (!mounted) return;
      setState(() => _state = PageState.error);
    }
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);
    final query = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索工单'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入工单号 / 标题 / 设备 / 负责人',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('清空'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('应用'),
          ),
        ],
      ),
    );

    if (query == null || !mounted) return;
    setState(() => _searchQuery = query);
  }

  List<WorkOrderModel> get _filteredWorkOrders {
    return _workOrders.where((wo) {
      if (_selectedStatus != '全部' && wo.status != _selectedStatus) {
        return false;
      }
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      return wo.id.toLowerCase().contains(query) ||
          wo.title.toLowerCase().contains(query) ||
          wo.device.toLowerCase().contains(query) ||
          wo.component.toLowerCase().contains(query) ||
          wo.assignee.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      state: _state,
      onRetry: _loadWorkOrders,
      emptyMessage: '暂无工单',
      child: Column(
        children: [
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusChip('全部'),
                            const SizedBox(width: 8),
                            _buildStatusChip('待处理'),
                            const SizedBox(width: 8),
                            _buildStatusChip('处理中'),
                            const SizedBox(width: 8),
                            _buildStatusChip('已完成'),
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
                      '时间:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTimeChip('近24h'),
                    const SizedBox(width: 8),
                    _buildTimeChip('近7d'),
                    const SizedBox(width: 8),
                    _buildTimeChip('近30d'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _showSearchDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredWorkOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final workOrder = _filteredWorkOrders[index];
                return _buildWorkOrderCard(workOrder);
              },
            ),
          ),
        ],
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

  Widget _buildTimeChip(String label) {
    final isSelected = _selectedTime == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTime = label;
        });
      },
      child: StatusChip(
        label: label,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildWorkOrderCard(WorkOrderModel workOrder) {
    Color statusColor;
    switch (workOrder.status) {
      case '待处理':
        statusColor = AppColors.warning;
        break;
      case '处理中':
        statusColor = AppColors.info;
        break;
      case '已完成':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.subText;
    }

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.workOrderDetail,
            arguments: WorkOrderDetailArgs(orderId: workOrder.id),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          workOrder.id,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            workOrder.status,
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workOrder.device} - ${workOrder.component}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workOrder.title,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.subText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          workOrder.assignee,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.subText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '更新: ${workOrder.updatedTime}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.subText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.subText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
