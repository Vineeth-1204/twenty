import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/vault_item.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vault_provider.dart';
import '../theme/app_theme.dart';
import 'add_edit_entry_screen.dart';
import 'generator_screen.dart';
import 'security_audit_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final vault = Provider.of<VaultProvider>(context, listen: false);
      if (auth.masterKey != null) {
        vault.loadVault(auth.masterKey!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const VaultTab(),
      const GeneratorScreen(),
      const SecurityAuditScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Listener(
        onPointerDown: (_) {
          Provider.of<AuthProvider>(context, listen: false).userActivityDetected();
        },
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock, color: AppTheme.primaryNeon),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: AppTheme.primaryNeon),
            label: 'Generator',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety, color: AppTheme.primaryNeon),
            label: 'Audit',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppTheme.primaryNeon),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditEntryScreen()),
                );
              },
              backgroundColor: AppTheme.primaryNeon,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'New Item',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ).animate().scale(duration: 300.ms)
          : null,
    );
  }
}

class VaultTab extends StatefulWidget {
  const VaultTab({super.key});

  @override
  State<VaultTab> createState() => _VaultTabState();
}

class _VaultTabState extends State<VaultTab> {
  final Set<String> _unmaskedItemIds = {};

  void _copyToClipboard(BuildContext context, String password) {
    if (password.isEmpty) return;
    Clipboard.setData(ClipboardData(text: password));
    HapticFeedback.mediumImpact();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final clearSec = settings.clipboardClearSeconds;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Password copied! Auto-clearing in ${clearSec}s.',
                style: GoogleFonts.outfit(),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Timer(Duration(seconds: clearSec), () async {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == password) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vaultProvider = Provider.of<VaultProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final items = vaultProvider.filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SecureVault',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              vaultProvider.showFavoritesOnly ? Icons.star : Icons.star_border,
              color: vaultProvider.showFavoritesOnly ? Colors.amber : null,
            ),
            tooltip: 'Filter Favorites',
            onPressed: () => vaultProvider.toggleFavoritesFilter(),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outlined),
            tooltip: 'Lock Vault',
            onPressed: () => authProvider.lockVault(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (q) => vaultProvider.setSearchQuery(q),
              style: GoogleFonts.outfit(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search title, username, URL, tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: vaultProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => vaultProvider.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),

          // Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                _buildCategoryChip('All', null, vaultProvider),
                ...VaultCategory.values.map(
                  (cat) => _buildCategoryChip(cat.displayName, cat, vaultProvider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Items List
          Expanded(
            child: vaultProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off_outlined,
                              size: 64,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Vault Items Found',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "+ New Item" to create your first encrypted record.',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isUnmasked = _unmaskedItemIds.contains(item.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddEditEntryScreen(existingItem: item)),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryNeon.withOpacity(0.15),
                                child: Icon(
                                  _getCategoryIcon(item.category),
                                  color: AppTheme.primaryNeon,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (item.isFavorite)
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.username.isNotEmpty)
                                    Text(
                                      item.username,
                                      style: GoogleFonts.outfit(fontSize: 13),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isUnmasked ? item.password : '••••••••••••',
                                          style: GoogleFonts.firaCode(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isUnmasked
                                                ? AppTheme.accentCyan
                                                : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isUnmasked ? Icons.visibility_off : Icons.visibility,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isUnmasked) {
                                              _unmaskedItemIds.remove(item.id);
                                            } else {
                                              _unmaskedItemIds.add(item.id);
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 18, color: AppTheme.primaryNeon),
                                        onPressed: () => _copyToClipboard(context, item.password),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (val) async {
                                  if (val == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddEditEntryScreen(existingItem: item)),
                                    );
                                  } else if (val == 'favorite') {
                                    if (authProvider.masterKey != null) {
                                      await vaultProvider.toggleFavorite(item.id, authProvider.masterKey!);
                                    }
                                  } else if (val == 'delete') {
                                    if (authProvider.masterKey != null) {
                                      await vaultProvider.deleteItem(item.id, authProvider.masterKey!);
                                    }
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(
                                    value: 'favorite',
                                    child: Text(item.isFavorite ? 'Remove Favorite' : 'Mark Favorite'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, VaultCategory? category, VaultProvider provider) {
    final isSelected = provider.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: GoogleFonts.outfit(fontSize: 13)),
        selectedColor: AppTheme.primaryNeon,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          provider.setSelectedCategory(category);
        },
      ),
    );
  }

  IconData _getCategoryIcon(VaultCategory cat) {
    switch (cat) {
      case VaultCategory.login:
        return Icons.person_outline;
      case VaultCategory.card:
        return Icons.credit_card_outlined;
      case VaultCategory.note:
        return Icons.note_alt_outlined;
      case VaultCategory.server:
        return Icons.dns_outlined;
      case VaultCategory.wifi:
        return Icons.wifi_outlined;
    }
  }
}
