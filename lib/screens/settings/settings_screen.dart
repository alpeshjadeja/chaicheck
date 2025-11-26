import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workspace_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final workspace = context.watch<WorkspaceProvider>().currentWorkspace;

    return ListView(
      children: [
        // User Profile Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user?.name[0].toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Workspace Section
        _buildSectionHeader('Workspace'),
        _buildListTile(
          icon: Icons.business,
          title: workspace?.name ?? 'No Workspace',
          subtitle: 'Current workspace',
          onTap: () {
            Navigator.of(context).pushNamed('/workspace-selector');
          },
        ),
        _buildListTile(
          icon: Icons.category,
          title: 'Manage Categories',
          onTap: () {
            Navigator.of(context).pushNamed('/categories');
          },
        ),

        const Divider(),

        // Account Section
        _buildSectionHeader('Account'),
        _buildListTile(
          icon: Icons.person,
          title: 'Edit Profile',
          onTap: () {
            // TODO: Navigate to edit profile
          },
        ),
        _buildListTile(
          icon: Icons.lock,
          title: 'Change Password',
          onTap: () {
            // TODO: Navigate to change password
          },
        ),
        _buildListTile(
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {
            // TODO: Navigate to notification settings
          },
        ),

        const Divider(),

        // App Section
        _buildSectionHeader('App'),
        _buildListTile(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            // TODO: Navigate to help
          },
        ),
        _buildListTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {
            // TODO: Navigate to privacy policy
          },
        ),
        _buildListTile(
          icon: Icons.info,
          title: 'About',
          subtitle: 'Version 1.0.0',
          onTap: () {
            // TODO: Show about dialog
          },
        ),

        const Divider(),

        // Logout
        _buildListTile(
          icon: Icons.logout,
          title: 'Logout',
          titleColor: Colors.red,
          onTap: () {
            _showLogoutDialog(context);
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
