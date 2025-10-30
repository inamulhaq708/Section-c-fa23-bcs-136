import 'dart:io';
import 'package:flutter/material.dart';
import 'package:doctor_app/model/patient_model.dart';
import 'package:doctor_app/theme/app_icons.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _avatar() {
    if (patient.imagePath != null && patient.imagePath!.isNotEmpty) {
      final f = File(patient.imagePath!);
      if (f.existsSync()) {
        return CircleAvatar(radius: 26, backgroundImage: FileImage(f));
      }
    }
    final isMale = patient.gender.toLowerCase() == 'male';
    return CircleAvatar(
      radius: 26,
      backgroundColor:
          (isMale ? AppIcons.primaryBlue : AppIcons.dangerRed).withOpacity(0.1),
      child: Center(
        child: AppIcons.genderIcon(
          isMale: isMale,
          size: 32,
          outlined: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withAlpha((0.95 * 255).round()),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          onTap: onTap,
          leading: _avatar(),
          title: Text(patient.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle:
              Text('${patient.age} yrs • ${patient.gender}\n${patient.phone}'),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    AppIcons.editPatient(
                      size: AppIcons.sizeSmall,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    const Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    AppIcons.deletePatient(
                      size: AppIcons.sizeSmall,
                      color: AppIcons.dangerRed,
                    ),
                    const SizedBox(width: 8),
                    const Text('Delete',
                        style: TextStyle(color: AppIcons.dangerRed)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
