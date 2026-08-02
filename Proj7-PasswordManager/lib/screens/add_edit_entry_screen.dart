import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/vault_item.dart';
import '../providers/auth_provider.dart';
import '../providers/vault_provider.dart';
import '../services/security_service.dart';
import '../theme/app_theme.dart';
import 'generator_screen.dart';

class AddEditEntryScreen extends StatefulWidget {
  final VaultItem? existingItem;

  const AddEditEntryScreen({super.key, this.existingItem});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _urlController;
  late TextEditingController _notesController;

  VaultCategory _selectedCategory = VaultCategory.login;
  bool _isFavorite = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _usernameController = TextEditingController(text: item?.username ?? '');
    _passwordController = TextEditingController(text: item?.password ?? '');
    _urlController = TextEditingController(text: item?.url ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _selectedCategory = item?.category ?? VaultCategory.login;
    _isFavorite = item?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _openGeneratorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: GeneratorScreen(
            isModal: true,
            onSelectPassword: (newPass) {
              setState(() {
                _passwordController.text = newPass;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
    final masterKey = authProvider.masterKey;

    if (masterKey == null) return;

    if (widget.existingItem != null) {
      final updated = widget.existingItem!.copyWith(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        url: _urlController.text.trim(),
        notes: _notesController.text.trim(),
        isFavorite: _isFavorite,
      );
      await vaultProvider.updateItem(updatedItem: updated, masterKey: masterKey);
    } else {
      await vaultProvider.addItem(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        url: _urlController.text.trim(),
        notes: _notesController.text.trim(),
        isFavorite: _isFavorite,
        masterKey: masterKey,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existingItem != null;

    final currentPass = _passwordController.text;
    final eval = SecurityService.evaluatePasswordStrength(currentPass);
    final score = eval['score'] as double;
    final label = eval['label'] as String;

    Color strengthColor;
    if (score < 0.3) {
      strengthColor = AppTheme.errorRed;
    } else if (score < 0.6) {
      strengthColor = AppTheme.warningOrange;
    } else if (score < 0.85) {
      strengthColor = AppTheme.accentCyan;
    } else {
      strengthColor = AppTheme.successGreen;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'New Vault Item'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.outfit(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Title / Item Name',
                  prefixIcon: Icon(Icons.title_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 16),

              // Category Selector
              DropdownButtonFormField<VaultCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                dropdownColor: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
                items: VaultCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.displayName, style: GoogleFonts.outfit()),
                  );
                }).toList(),
                onChanged: (cat) {
                  if (cat != null) setState(() => _selectedCategory = cat);
                },
              ),

              const SizedBox(height: 16),

              // Username Field
              TextFormField(
                controller: _usernameController,
                style: GoogleFonts.outfit(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Username / Email / Account ID',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.firaCode(fontSize: 16),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryNeon),
                        tooltip: 'Generate Strong Password',
                        onPressed: _openGeneratorModal,
                      ),
                    ],
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a password' : null,
              ),

              if (currentPass.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Strength: ',
                      style: GoogleFonts.outfit(fontSize: 13, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    ),
                    Text(
                      label,
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: strengthColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score,
                    minHeight: 4,
                    backgroundColor: (isDark ? Colors.white10 : Colors.black12),
                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // URL Field
              TextFormField(
                controller: _urlController,
                style: GoogleFonts.outfit(fontSize: 16),
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Website URL / App Link',
                  prefixIcon: Icon(Icons.link_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                style: GoogleFonts.outfit(fontSize: 15),
                decoration: const InputDecoration(
                  labelText: 'Secure Notes & Extra Details',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveEntry,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Update Entry' : 'Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
