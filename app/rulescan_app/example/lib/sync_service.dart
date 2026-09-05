import 'db_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SyncService {
  
  // This is a placeholder for Stage 07 Background Sync
  // In Phase 3, this will be wired to a WorkManager background task
  static Future<String> syncOfflineData() async {
    print("--- Starting Offline Sync ---");
    final unsynced = await DBHelper.instance.getUnsyncedInspections();
    
    if (unsynced.isEmpty) {
      return "No unsynced records found. Everything is up to date!";
    }

    List<Map<String, dynamic>> payload = [];
    for (var record in unsynced) {
      Map<String, dynamic> mutableRecord = Map<String, dynamic>.from(record);
      
      // FIX: mobile_id collision. If the app is reinstalled, id starts from 1 again.
      // To ensure globally unique but deterministic IDs for idempotency, we combine 
      // the local ID with the creation timestamp's epoch.
      int uniqueMobileId = record['id'] + DateTime.parse(record['timestamp']).millisecondsSinceEpoch;
      mutableRecord['id'] = uniqueMobileId;

      String? imagePath = mutableRecord['image_path'];
      if (imagePath != null) {
        try {
          File imgFile = File(imagePath);
          if (await imgFile.exists()) {
             List<int> imageBytes = await imgFile.readAsBytes();
             mutableRecord['image_base64'] = base64Encode(imageBytes);
          }
        } catch (_) {}
      }
      payload.add(mutableRecord);
    }
    
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.35:3001/api/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'inspections': payload}),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
            for (var record in unsynced) {
                await DBHelper.instance.markAsSynced(record['id']);
            }
            return "✅ Successfully synced ${resData['inserted']} records to Dashboard!";
        }
      }
      return "❌ Server error: ${response.statusCode}";
    } catch (e) {
      return "❌ Network Error (Firewall blocking?): $e";
    }
  }
}
