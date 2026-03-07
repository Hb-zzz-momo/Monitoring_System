import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onSwitchToDevices;

  const ProfileTab({super.key, this.onSwitchToDevices});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificationsEnabled = true;

  String _firstChar(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _readUserText(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  Future<void> _logout() async {
    await logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final username = _readUserText(user?['username']);
    final role = _readUserText(user?['role']);
    final displayName = _readUserText(user?['displayName']);
    final email = _readUserText(user?['email']);
    final title =
        displayName.isNotEmpty ? displayName : (username.isNotEmpty ? username : '未登录用户');
    final subtitle = email.isNotEmpty
        ? email
        : (username.isNotEmpty ? '账号: $username' : '请先登录');
    final badge = role.isNotEmpty ? role : 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          // Profile card
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _firstChar(title),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Name and account
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '角色: $badge',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Logout button
                OutlinedButton(
                  onPressed: () async {
                    await _logout();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    '退出',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Device management section
          Container(
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '设备管理',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.devices,
                  title: '已绑定设备',
                  subtitle: '4台设备',
                  onTap: () {
                    widget.onSwitchToDevices?.call();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Notification settings section
          Container(
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '通知设置',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('推送通知'),
                  subtitle: Text(
                    '接收告警和工单通知',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Threshold display section
          Container(
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '阈值展示',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildThresholdItem('温度', '75', '℃'),
                      const SizedBox(height: 12),
                      _buildThresholdItem('电压', '240', 'V'),
                      const SizedBox(height: 12),
                      _buildThresholdItem('电流', '20', 'A'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // About section
          Container(
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '关于',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.info_outline,
                  title: '版本信息',
                  subtitle: 'v1.0.0',
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私政策',
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: '日志导出',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subText,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.subText,
      ),
      onTap: onTap,
    );
  }

  Widget _buildThresholdItem(String label, String value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
