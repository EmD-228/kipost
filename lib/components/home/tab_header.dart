import 'package:flutter/material.dart';
import 'package:kipost/models/tab_config.dart';

class TabHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<TabConfig> tabs;

  const TabHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSectionTitle(context),
          _buildCustomTabBar(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return TabBar(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      indicator: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(25),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey.shade600,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      tabs: tabs.map((tab) => _buildTabItem(tab)).toList(),
    );
  }

  Widget _buildTabItem(TabConfig config) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 16),
            const SizedBox(width: 8),
            Text(config.label),
          ],
        ),   
      ),
    );
  }
}
