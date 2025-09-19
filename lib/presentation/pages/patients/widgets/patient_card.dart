import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/presentation/providers/patient_provider.dart';

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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar más grande para grid
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primary,
                child: Text(
                  _getInitials(patient.name),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nombre
              Text(
                patient.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Edad y género
              Text(
                '${patient.age} años • ${patient.gender}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Teléfono
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      patient.phone,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Menú de acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.history, size: 20),
                    onPressed: () => _handleMenuAction(context, ref, 'history'),
                    tooltip: 'Ver consultas',
                  ),
                  IconButton(
                    icon: const Icon(Icons.medical_services, size: 20),
                    onPressed: () => _handleMenuAction(context, ref, 'consultation'),
                    tooltip: 'Nueva consulta',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, ref, value),
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, ref, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'history',
                        child: Row(
                          children: [
                            Icon(Icons.history, size: 20),
                            SizedBox(width: 8),
                            Text('Ver Consultas'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'consultation',
                        child: Row(
                          children: [
                            Icon(Icons.medical_services, size: 20),
                            SizedBox(width: 8),
                            Text('Nueva Consulta'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Información de contacto
              _buildInfoRow(
                context,
                Icons.phone,
                'Teléfono',
                patient.phone,
              ),

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

  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'history':
        if (patient.id != null) {
          context.go('/patients/${patient.id}');
        }
        break;

      case 'consultation':
        if (patient.id != null) {
          context.go('/patients/${patient.id}/consultation');
        }
        break;

      case 'edit':
        // TODO: Implementar edición de paciente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Función de editar próximamente')),
        );
        break;

      case 'delete':
        final confirmed = await _showDeleteConfirmationDialog(context);
        if (confirmed && patient.id != null) {
          try {
            await ref.read(patientProvider.notifier).removePatient(patient.id!);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${patient.name} ha sido eliminado')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al eliminar: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        break;
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: '¿Estás seguro de que deseas eliminar a '),
              TextSpan(
                text: patient.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nEsta acción no se puede deshacer y se eliminarán también todas las consultas asociadas.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }
}