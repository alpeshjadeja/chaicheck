import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../tasks/task_list_screen.dart';
import '../tasks/dashboard_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TaskListScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final workspaceProvider = context.read<WorkspaceProvider>();
    final taskProvider = context.read<TaskProvider>();

    if (authProvider.currentUser != null) {
      await workspaceProvider.loadWorkspaces(authProvider.currentUser!.id);
      
      if (workspaceProvider.currentWorkspace != null) {
        await taskProvider.loadTasks(workspaceProvider.currentWorkspace!.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = context.watch<WorkspaceProvider>();

    if (workspaceProvider.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading workspace...'),
      );
    }

    if (workspaceProvider.currentWorkspace == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No workspace found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/workspace-selector');
                },
                child: const Text('Create Workspace'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(workspaceProvider.currentWorkspace!.name),
        actions: [
          if (workspaceProvider.workspaces.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () {
                Navigator.of(context).pushNamed('/workspace-selector');
              },
              tooltip: 'Switch Workspace',
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/create-task');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
