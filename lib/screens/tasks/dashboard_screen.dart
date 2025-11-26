import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        // Reload tasks
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Today',
                      count: taskProvider.todayTasks.length,
                      color: Colors.blue,
                      icon: Icons.today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Overdue',
                      count: taskProvider.overdueTasks.length,
                      color: Colors.red,
                      icon: Icons.warning,
                    ),
                  ),
                ],
              ),
            ),

            // Today's Tasks Section
            _buildSection(
              context,
              title: "Today's Tasks",
              tasks: taskProvider.todayTasks,
              emptyMessage: 'No tasks due today',
            ),

            const SizedBox(height: 16),

            // Overdue Tasks Section
            if (taskProvider.overdueTasks.isNotEmpty)
              _buildSection(
                context,
                title: 'Overdue Tasks',
                tasks: taskProvider.overdueTasks,
                emptyMessage: 'No overdue tasks',
              ),

            const SizedBox(height: 16),

            // Upcoming Tasks Section
            _buildSection(
              context,
              title: 'Upcoming Tasks',
              tasks: taskProvider.incompleteTasks
                  .where((task) => !task.isOverdue && !task.isDueToday)
                  .take(5)
                  .toList(),
              emptyMessage: 'No upcoming tasks',
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List tasks,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (tasks.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // Navigate to full task list
                  },
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                emptyMessage,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/task-detail',
                    arguments: task,
                  );
                },
                onToggleComplete: () {
                  context.read<TaskProvider>().toggleTaskCompletion(task);
                },
              );
            },
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
