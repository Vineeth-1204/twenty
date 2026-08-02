import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/vault_item.dart';
import '../providers/vault_provider.dart';
import '../theme/app_theme.dart';
import 'add_edit_entry_screen.dart';

class SecurityAuditScreen extends StatelessWidget {
  const SecurityAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final vaultProvider = Provider.of<VaultProvider>(context);
    final auditData = vaultProvider.calculateSecurityAudit();

    final healthScore = auditData['healthScore'] as int;
    final weakCount = auditData['weakCount'] as int;
    final reusedCount = auditData['reusedCount'] as int;
    final oldCount = auditData['oldCount'] as int;
    final totalCount = auditData['totalCount'] as int;
    final weakItems = auditData['weakItems'] as List<VaultItem>;
    final reusedItems = auditData['reusedItems'] as List<VaultItem>;

    Color scoreColor;
    if (healthScore < 50) {
      scoreColor = AppTheme.errorRed;
    } else if (healthScore < 75) {
      scoreColor = AppTheme.warningOrange;
    } else {
      scoreColor = AppTheme.successGreen;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Audit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score Gauge Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scoreColor.withOpacity(0.12),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: healthScore / 100.0,
                          strokeWidth: 12,
                          backgroundColor: isDark ? Colors.white10 : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$healthScore',
                            style: GoogleFonts.outfit(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                          Text(
                            'Vault Score',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    healthScore >= 80
                        ? 'Great Job! Your vault security score is optimal.'
                        : 'Action Recommended: Fix weak and reused passwords to prevent unauthorized access.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(duration: 400.ms),

            const SizedBox(height: 20),

            // Summary Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total Items', '$totalCount', Icons.shield_outlined, AppTheme.primaryNeon, isDark),
                _buildStatCard('Weak Passwords', '$weakCount', Icons.warning_amber_rounded, AppTheme.errorRed, isDark),
                _buildStatCard('Reused Passwords', '$reusedCount', Icons.copy_rounded, AppTheme.warningOrange, isDark),
                _buildStatCard('Outdated (>90d)', '$oldCount', Icons.history_outlined, AppTheme.accentCyan, isDark),
              ],
            ),

            const SizedBox(height: 28),

            // Weak Passwords List
            if (weakItems.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Weak Passwords (${weakItems.length})',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...weakItems.map((item) => _buildItemIssueTile(context, item, 'Weak Password', AppTheme.errorRed, isDark)),
              const SizedBox(height: 20),
            ],

            // Reused Passwords List
            if (reusedItems.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reused Passwords (${reusedItems.length})',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...reusedItems.map((item) => _buildItemIssueTile(context, item, 'Reused across accounts', AppTheme.warningOrange, isDark)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemIssueTile(BuildContext context, VaultItem item, String issue, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.security, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  issue,
                  style: GoogleFonts.outfit(fontSize: 12, color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryNeon),
            tooltip: 'Fix Password',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditEntryScreen(existingItem: item)),
              );
            },
          ),
        ],
      ),
    );
  }
}
