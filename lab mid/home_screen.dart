import 'package:flutter/material.dart';
import 'package:doctor_app/database/hive_helper.dart';
import 'package:doctor_app/model/patient_model.dart';
import 'package:doctor_app/screens/add_patient.dart';
import 'package:doctor_app/screens/patient_detail_screen.dart';
import 'package:doctor_app/screens/edit_patient.dart';
import 'package:doctor_app/patient_card.dart';
import 'package:doctor_app/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  final String? filterGender;

  const HomeScreen({super.key, this.filterGender});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = HiveHelper.instance;
  List<Patient> patients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => loading = true);
    try {
      if (widget.filterGender != null) {
        patients = await db.getPatientsByGender(widget.filterGender!);
      } else {
        patients = await db.getAllPatients();
      }
    } catch (_) {
      patients = [];
    }
    setState(() => loading = false);
  }

  Future<void> _deletePatient(int id) async {
    await db.deletePatient(id);
    await _loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // back button if we're filtering
        leading: widget.filterGender != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    // quick open the bottom menu
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            // Quick actions
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                'Quick Actions',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.person_add_outlined,
                                color: kPrimaryColor,
                              ),
                              title: const Text('Add Patient'),
                              onTap: () {
                                Navigator.pop(context);
                                _gotoAdd();
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.info_outline,
                                color: kPrimaryColor,
                              ),
                              title: const Text('About'),
                              onTap: () {
                                Navigator.pop(context);
                                showAboutDialog(
                                    context: context,
                                    applicationName: 'Doctor App');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: ClipOval(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.asset('assets/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                                color: kPrimaryColor
                                    .withAlpha((0.12 * 255).round()),
                                child: const Icon(Icons.medical_services,
                                    color: kPrimaryColor),
                              )),
                    ),
                  ),
                ),
              ),
        title: Text(widget.filterGender != null
            ? '${widget.filterGender} Patients'
            : 'Doctor App'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            tooltip: 'Add patient',
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _gotoAdd,
          ),
          if (widget.filterGender == null)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'add') _gotoAdd();
                if (v == 'about')
                  showAboutDialog(
                      context: context, applicationName: 'Doctor App');
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.person_add_outlined,
                          size: 20, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('Add Patient'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('About'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          // subtle background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FBFF), Color(0xFFEFF6FF)],
              ),
            ),
          ),
          SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : patients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kPrimaryColor
                                        .withAlpha((0.12 * 255).round()),
                                  ),
                                  child: const Icon(Icons.medical_services,
                                      size: 56, color: kPrimaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                                widget.filterGender != null
                                    ? 'No ${widget.filterGender} Patients'
                                    : 'Welcome to Doctor App',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                widget.filterGender != null
                                    ? 'Add a patient to get started.'
                                    : 'Manage your patients easily.',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _gotoAdd,
                              icon: const Icon(Icons.person_add),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 6),
                                child: Text('+ Add Patient',
                                    style: TextStyle(fontSize: 16)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPatients,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          itemCount: patients.length,
                          itemBuilder: (context, i) {
                            final p = patients[i];
                            return PatientCard(
                              patient: p,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        PatientDetailScreen(patient: p)),
                              ).then((_) => _loadPatients()),
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EditPatientScreen(patient: p)),
                              ).then((_) => _loadPatients()),
                              onDelete: () => showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete patient?'),
                                  content:
                                      Text('Delete ${p.name} permanently?'),
                                  actions: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () => Navigator.pop(context),
                                      label: const Text('Cancel'),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20, color: Colors.red),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deletePatient(p.id!);
                                      },
                                      label: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoAdd,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  void _gotoAdd() {
    Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddPatientScreen()))
        .then((_) => _loadPatients());
  }
}
