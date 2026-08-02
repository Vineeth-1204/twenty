import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vault_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChangePinDialog(BuildContext context) {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Change Security PIN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current 4-Digit PIN'),
                validator: (val) => val == null || val.length != 4 ? 'Enter 4 digits' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New 4-Digit PIN'),
                validator: (val) => val == null || val.length != 4 ? 'Enter 4 digits' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                try {
                  await authProvider.changePin(oldPinController.text, newPinController.text);
                  if (context.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN successfully updated!'), backgroundColor: AppTheme.successGreen),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.errorRed),
                    );
                  }
                }
              }
            },
            child: const Text('Update PIN'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Export Encrypted Backup', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set a master password to encrypt your exported vault backup file (.securevault).',
              style: GoogleFonts.outfit(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Backup Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pass = passwordController.text.trim();
              if (pass.isEmpty) return;

              final vault = Provider.of<VaultProvider>(context, listen: false);
              try {
                final path = await StorageService.exportBackup(vault.allItems, pass);
                if (context.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Encrypted Backup saved to: $path'),
                      duration: const Duration(seconds: 5),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e'), backgroundColor: AppTheme.errorRed),
                  );
                }
              }
            },
            child: const Text('Export File'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final pathController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Import Encrypted Backup', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pathController,
              decoration: const InputDecoration(labelText: 'Full Path to .securevault File'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Backup Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = pathController.text.trim();
              final pass = passwordController.text.trim();
              if (path.isEmpty || pass.isEmpty) return;

              final auth = Provider.of<AuthProvider>(context, listen: false);
              final vault = Provider.of<VaultProvider>(context, listen: false);

              try {
                final items = await StorageService.importBackup(path, pass);
                if (auth.masterKey != null) {
                  for (final item in items) {
                    await vault.addItem(
                      title: item.title,
                      category: item.category,
                      username: item.username,
                      password: item.password,
                      url: item.url,
                      notes: item.notes,
                      masterKey: auth.masterKey!,
                      isFavorite: item.isFavorite,
                    );
                  }
                }

                if (context.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully imported ${items.length} items!'), backgroundColor: AppTheme.successGreen),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import error: $e'), backgroundColor: AppTheme.errorRed),
                  );
                }
              }
            },
            child: const Text('Import Backup'),
          ),
        ],
      ),
    );
  }

  void _showWipeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Wipe All Data?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.errorRed)),
        content: Text(
          'This will permanently delete all stored passwords, key salt, and setup profile. This action cannot be undone.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.resetApp();
            },
            child: const Text('Yes, Wipe Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Security Section
          _buildSectionHeader('Security & Lock', isDark),
          _buildTile(
            icon: Icons.pin_outlined,
            title: 'Change 4-Digit PIN',
            subtitle: 'Update your master decryption PIN',
            onTap: () => _showChangePinDialog(context),
            isDark: isDark,
          ),
          _buildTile(
            icon: Icons.timer_outlined,
            title: 'Auto-Lock Timeout',
            subtitle: 'Lock vault after background inactivity',
            trailing: DropdownButton<int>(
              value: settings.autoLockSeconds,
              underline: const SizedBox.shrink(),
              dropdownColor: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
              items: const [
                DropdownMenuItem(value: 30, child: Text('30 Seconds')),
                DropdownMenuItem(value: 60, child: Text('1 Minute')),
                DropdownMenuItem(value: 300, child: Text('5 Minutes')),
              ],
              onChanged: (val) {
                if (val != null) {
                  settings.setAutoLockSeconds(val);
                  auth.setAutoLockSeconds(val);
                }
              },
            ),
            isDark: isDark,
          ),
          _buildTile(
            icon: Icons.content_copy_outlined,
            title: 'Clipboard Auto-Clear',
            subtitle: 'Automatically clear copied passwords',
            trailing: DropdownButton<int>(
              value: settings.clipboardClearSeconds,
              underline: const SizedBox.shrink(),
              dropdownColor: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 Seconds')),
                DropdownMenuItem(value: 30, child: Text('30 Seconds')),
                DropdownMenuItem(value: 60, child: Text('60 Seconds')),
              ],
              onChanged: (val) {
                if (val != null) settings.setClipboardClearSeconds(val);
              },
            ),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance', isDark),
          _buildTile(
            icon: Icons.palette_outlined,
            title: 'Theme Mode',
            subtitle: 'Select dark or light appearance',
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              dropdownColor: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
              items: const [
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Obsidian')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light Crisp')),
                DropdownMenuItem(value: ThemeMode.system, child: Text('System Standard')),
              ],
              onChanged: (mode) {
                if (mode != null) settings.setThemeMode(mode);
              },
            ),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Backup & Sync Section
          _buildSectionHeader('Data & Backup', isDark),
          _buildTile(
            icon: Icons.file_upload_outlined,
            title: 'Export Encrypted Backup',
            subtitle: 'Save encrypted .securevault JSON file',
            onTap: () => _showExportDialog(context),
            isDark: isDark,
          ),
          _buildTile(
            icon: Icons.file_download_outlined,
            title: 'Import Encrypted Backup',
            subtitle: 'Restore credentials from backup file',
            onTap: () => _showImportDialog(context),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Vault Actions
          _buildSectionHeader('Vault Session', isDark),
          _buildTile(
            icon: Icons.lock_outline,
            title: 'Lock Vault Now',
            subtitle: 'Clear key from memory and return to lock screen',
            iconColor: AppTheme.warningOrange,
            onTap: () => auth.lockVault(),
            isDark: isDark,
          ),
          _buildTile(
            icon: Icons.delete_forever_outlined,
            title: 'Wipe All Data & Reset',
            subtitle: 'Permanently remove all credentials and keys',
            iconColor: AppTheme.errorRed,
            onTap: () => _showWipeConfirmation(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryNeon,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? AppTheme.accentCyan),
        title: Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}
