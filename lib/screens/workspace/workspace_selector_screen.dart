import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workspace_provider.dart';
import '../../models/workspace.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

class WorkspaceSelectorScreen extends StatefulWidget {
  const WorkspaceSelectorScreen({super.key});

  @override
  State<WorkspaceSelectorScreen> createState() => _WorkspaceSelectorScreenState();
}

class _WorkspaceSelectorScreenState extends State<WorkspaceSelectorScreen> {
  @override
  void initState() {
    super.initState();
    _loadWorkspaces();
  }

  Future<void> _loadWorkspaces() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<WorkspaceProvider>().loadWorkspaces(userId);
    }
  }

  void _showCreateWorkspaceDialog() {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Workspace'),
        content: Form(
          key: formKey,
          child: CustomTextField(
            label: 'Workspace Name',
            hint: 'e.g., My Restaurant',
            controller: nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a workspace name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final userId = context.read<AuthProvider>().currentUser?.id;
                if (userId != null) {
                  final workspace = Workspace(
                    id: '',
                    name: nameController.text.trim(),
                    ownerId: userId,
                    memberIds: [userId],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  try {
                    await context.read<WorkspaceProvider>().createWorkspace(workspace);
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = context.watch<WorkspaceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Workspace'),
      ),
      body: workspaceProvider.isLoading
          ? const LoadingIndicator(message: 'Loading workspaces...')
          : workspaceProvider.workspaces.isEmpty
              ? EmptyState(
                  title: 'No Workspaces',
                  message: 'Create your first workspace to get started',
                  icon: Icons.business,
                  actionText: 'Create Workspace',
                  onAction: _showCreateWorkspaceDialog,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workspaceProvider.workspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = workspaceProvider.workspaces[index];
                    final isSelected = workspaceProvider.currentWorkspace?.id == workspace.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            workspace.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          workspace.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${workspace.memberIds.length} members'),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          workspaceProvider.setCurrentWorkspace(workspace);
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateWorkspaceDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Workspace'),
      ),
    );
  }
}
