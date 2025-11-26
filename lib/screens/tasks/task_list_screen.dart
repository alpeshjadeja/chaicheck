import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Column(
      children: [
        // Search Bar
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'All Tasks (${taskProvider.tasks.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Show filter dialog
                  },
                ),
              ],
            ),
          ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Overdue'),
          ],
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(
                _searchController.text.isEmpty
                    ? taskProvider.tasks
                    : taskProvider.searchTasks(_searchController.text),
              ),
              _buildTaskList(taskProvider.incompleteTasks),
              _buildTaskList(taskProvider.completedTasks),
              _buildTaskList(taskProvider.overdueTasks),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List tasks) {
    if (tasks.isEmpty) {
      return EmptyState(
        title: 'No Tasks',
        message: 'Create a new task to get started',
        icon: Icons.task_alt,
        actionText: 'Create Task',
        onAction: () {
          Navigator.of(context).pushNamed('/create-task');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Reload tasks
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
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
    );
  }
}
