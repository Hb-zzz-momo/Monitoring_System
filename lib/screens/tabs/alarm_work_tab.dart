import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_args.dart';
import '../../components/common_widgets.dart';
import '../../services/api_service.dart';
import '../../models/alarm_model.dart';
import '../../models/work_order_model.dart';

part 'alarm_work/alarm_center_view.dart';
part 'alarm_work/work_orders_view.dart';

class AlarmWorkTab extends StatefulWidget {
  const AlarmWorkTab({super.key});

  @override
  State<AlarmWorkTab> createState() => _AlarmWorkTabState();
}

class _AlarmWorkTabState extends State<AlarmWorkTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('告警/工单'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.text,
              tabs: const [
                Tab(text: '告警'),
                Tab(text: '工单'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AlarmCenterView(),
          WorkOrdersView(),
        ],
      ),
    );
  }
}
