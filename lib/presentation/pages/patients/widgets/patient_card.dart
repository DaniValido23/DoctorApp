import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:doctor_app/data/models/patient.dart';

class PatientCard extends ConsumerWidget {
  final Patient patient;
  final VoidCallback? onTap;
  final bool isGridLayout;

  const PatientCard({
    super.key,
    required this.patient,
    this.onTap,
    this.isGridLayout = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isGridLayout) {
      return _buildGridCard(context, ref, theme, colorScheme);
    } else {
      return _buildListCard(context, ref, theme, colorScheme);
    }
  }

  Widget _buildGridCard(BuildContext context, WidgetRef ref, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () {
          if (patient.id != null) {
            context.go('/patients/${patient.id}');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar más grande
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.primary,
                child: Text(
                  _getInitials(patient.name),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nombre
              Text(
                patient.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Edad y género
              Text(
                '${patient.age} años • ${patient.gender}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Teléfono - clickeable para WhatsApp
              InkWell(
                onTap: () => _openWhatsApp(patient.phone),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          patient.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, WidgetRef ref, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () {
          if (patient.id != null) {
            context.go('/patients/${patient.id}');
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con avatar y nombre
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      _getInitials(patient.name),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.age} años • ${patient.gender}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Información de contacto
              _buildPhoneRow(context, patient.phone),

              if (patient.email?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  Icons.email,
                  'Email',
                  patient.email!,
                ),
              ],

              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.cake,
                'Fecha de nacimiento',
                DateFormat('dd/MM/yyyy').format(patient.birthDate),
              ),

              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.access_time,
                'Registrado',
                _formatRelativeDate(patient.createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneRow(BuildContext context, String phoneNumber) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.phone,
          size: 16,
          color: Colors.green[700],
        ),
        const SizedBox(width: 8),
        Text(
          'Teléfono: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => _openWhatsApp(phoneNumber),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phoneNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chat,
                    size: 12,
                    color: Colors.green[700],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Limpiar el número telefónico (remover espacios, guiones, paréntesis)
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Agregar prefijo +52 de México si no lo tiene
      if (!cleanNumber.startsWith('+52') && !cleanNumber.startsWith('52')) {
        cleanNumber = '+52$cleanNumber';
      } else if (cleanNumber.startsWith('52') && !cleanNumber.startsWith('+52')) {
        cleanNumber = '+$cleanNumber';
      }

      // URL de WhatsApp
      final whatsappUrl = 'https://wa.me/$cleanNumber';
      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Si no se puede abrir WhatsApp, intentar abrir el dialer
        final telUrl = 'tel:$cleanNumber';
        final telUri = Uri.parse(telUrl);

        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      }
    } catch (e) {
      // En caso de error, no hacer nada para mantener la UX fluida
      debugPrint('Error opening WhatsApp: $e');
    }
  }

}