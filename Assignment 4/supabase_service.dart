import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://demo.supabase.co';
  static const String supabaseAnonKey = 'demo-key';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  // Demo data storage (in-memory for demonstration)
  static List<Submission> _demoSubmissions = [];
  static int _nextId = 1;

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      print('Supabase initialization failed (demo mode): $e');
      // Continue in demo mode
    }
  }

  // Create a new submission
  static Future<bool> createSubmission(Submission submission) async {
    try {
      await client
          .from('submissions')
          .insert(submission.toJson());
      return true;
    } catch (e) {
      print('Using demo mode for create: $e');
      // Demo mode - store in memory
      final newSubmission = Submission(
        id: _nextId++,
        fullName: submission.fullName,
        email: submission.email,
        phoneNumber: submission.phoneNumber,
        address: submission.address,
        gender: submission.gender,
        createdAt: DateTime.now(),
      );
      _demoSubmissions.add(newSubmission);
      return true;
    }
  }

  // Read all submissions
  static Future<List<Submission>> getSubmissions() async {
    try {
      final response = await client
          .from('submissions')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Submission.fromJson(json))
          .toList();
    } catch (e) {
      print('Using demo mode for read: $e');
      // Demo mode - return in-memory data
      return List.from(_demoSubmissions.reversed);
    }
  }

  // Update a submission
  static Future<bool> updateSubmission(Submission submission) async {
    try {
      await client
          .from('submissions')
          .update(submission.toJson())
          .eq('id', submission.id!);
      return true;
    } catch (e) {
      print('Using demo mode for update: $e');
      // Demo mode - update in-memory data
      final index = _demoSubmissions.indexWhere((s) => s.id == submission.id);
      if (index != -1) {
        _demoSubmissions[index] = submission;
        return true;
      }
      return false;
    }
  }

  // Delete a submission
  static Future<bool> deleteSubmission(int id) async {
    try {
      await client
          .from('submissions')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Using demo mode for delete: $e');
      // Demo mode - remove from in-memory data
      _demoSubmissions.removeWhere((s) => s.id == id);
      return true;
    }
  }
}