import 'db_helper.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class SyncService {
  
  // This is a placeholder for Stage 07 Background Sync
  // In Phase 3, this will be wired to a WorkManager background task
  static Future<String> syncOfflineData() async {
    print("--- Starting Offline Sync ---");
    final unsynced = await DBHelper.instance.getUnsyncedInspections();
    
    if (unsynced.isEmpty) {
      return "No unsynced records found. Everything is up to date!";
    }

    final supabase = Supabase.instance.client;
    if (supabase.auth.currentUser == null) {
      return "❌ Error: Not logged in. Please log in first.";
    }

    int successCount = 0;

    for (var record in unsynced) {
      try {
        String? storagePath;
        String? imagePath = record['image_path'];
        
        // 1. Upload Image to Storage (if exists)
        if (imagePath != null) {
          File imgFile = File(imagePath);
          if (await imgFile.exists()) {
             final fileName = 'evidence_${DateTime.now().millisecondsSinceEpoch}${p.extension(imgFile.path)}';
             await supabase.storage.from('inspection-evidence').upload(fileName, imgFile);
             storagePath = fileName;
          }
        }

        // 2. Insert into Products
        final product = await supabase.from('products').insert({
          'brand': 'Unknown',
          'product_name': 'Scanned Product',
          'manufacturer': 'Unknown',
          'category': record['category'],
          'barcode': record['barcode'] ?? '',
        }).select().single();

        // 3. Insert into Inspections
        String violationsStr = record['violations'] ?? '';
        String overallStatus = violationsStr.isEmpty ? 'PASS' : 'FAIL';
        
        final insp = await supabase.from('inspections').insert({
          'officer_id': supabase.auth.currentUser!.id,
          'product_id': product['id'],
          'source_type': 'CAMERA',
          'category': record['category'],
          'overall_status': overallStatus,
          'latitude': record['latitude'] ?? 0.0,
          'longitude': record['longitude'] ?? 0.0,
          'remarks': violationsStr,
        }).select().single();

        // 4. Insert into Evidence
        if (storagePath != null) {
          await supabase.from('evidence').insert({
            'inspection_id': insp['id'],
            'evidence_type': 'ORIGINAL_IMAGE',
            'storage_path': storagePath
          });
        }

        // If successful, mark as synced locally
        await DBHelper.instance.markAsSynced(record['id']);
        successCount++;
        
      } catch (e) {
        print("Sync error for record ${record['id']}: $e");
      }
    }
    
    if (successCount == unsynced.length) {
      return "✅ Successfully synced $successCount records to Supabase Cloud!";
    } else {
      return "⚠️ Synced $successCount out of ${unsynced.length} records. Check logs for errors.";
    }
  }
}
