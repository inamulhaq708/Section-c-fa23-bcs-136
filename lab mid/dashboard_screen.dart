import 'package:flutter/material.dart';
import 'package:doctor_app/screens/add_patient.dart';
import 'package:doctor_app/screens/home_screen.dart';
import 'package:doctor_app/database/hive_helper.dart';
import 'package:doctor_app/model/patient_model.dart';
import 'package:doctor_app/screens/patient_detail_screen.dart';
import 'package:doctor_app/theme/app_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  final _db = HiveHelper.instance;
  List<Patient> _searchResults = [];
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final allPatients = await _db.getAllPatients();
      final results = allPatients.where((p) {
        final searchLower = query.toLowerCase();
        return p.name.toLowerCase().contains(searchLower) ||
            p.phone.toLowerCase().contains(searchLower);
      }).toList();

      setState(() {
        _searchResults = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _loading = false;
      });
    }
  }

  Widget _buildSearchResults() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No patients found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final patient = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppIcons.primaryBlue.withOpacity(0.1),
            child: AppIcons.genderIcon(
              isMale: patient.gender.toLowerCase() == 'male',
              size: 24,
              color: AppIcons.primaryBlue,
            ),
          ),
          title: Text(patient.name),
          subtitle: Text('${patient.age} yrs • ${patient.phone}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailScreen(patient: patient),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Doctor Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search patients by name or phone',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) => _performSearch(value),
              ),
            ),
            if (_searchResults.isNotEmpty || _loading) ...[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildSearchResults(),
                ),
              )
            ] else ...[
              const SizedBox(height: 20),
              _buildDashboardButton(
                context,
                icon: Icons.person_add,
                color: Colors.blueAccent,
                label: 'Add Patient',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPatientScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDashboardButton(
                context,
                icon: Icons.male,
                color: Colors.lightBlue,
                label: 'Male Patients',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomeScreen(filterGender: 'Male')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDashboardButton(
                context,
                icon: Icons.female,
                color: Colors.pinkAccent,
                label: 'Female Patients',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const HomeScreen(filterGender: 'Female')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Reusable button widget
  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label == 'Add Patient')
              AppIcons.addPatient(size: 28, color: Colors.white)
            else if (label == 'Male Patients')
              AppIcons.genderIcon(isMale: true, size: 28, color: Colors.white)
            else if (label == 'Female Patients')
              AppIcons.genderIcon(isMale: false, size: 28, color: Colors.white)
            else
              Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
