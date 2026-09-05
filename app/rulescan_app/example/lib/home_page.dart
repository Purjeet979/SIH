import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'camera_ocr_page.dart';
import 'history_page.dart';
import 'sync_service.dart';
import 'review_page.dart';
import 'barcode_page.dart';
import 'theme.dart';
import 'package:geolocator/geolocator.dart';
import 'admin_dashboard_view.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final String role;
  const HomePage({super.key, this.role = 'officer'});

  @override
  Widget build(BuildContext context) {
    if (role == 'admin') {
      return AdminDashboardView(
        onSwitchRole: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        },
      );
    }
    return _buildOfficerDashboard(context);
  }

  Future<void> _uploadScreenshot(BuildContext context) async {
    await Geolocator.checkPermission().then((perm) async {
      if (perm == LocationPermission.denied) await Geolocator.requestPermission();
    });

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analyzing screenshot...')),
      );
    }

    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String allText = recognizedText.text;
      textRecognizer.close();
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewPage(ocrText: allText, imagePath: image.path)
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    }
  }

  Future<void> _ensureLocationPermission() async {
    await Geolocator.checkPermission().then((perm) async {
      if (perm == LocationPermission.denied) await Geolocator.requestPermission();
    });
  }

  Widget _buildOfficerDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Officer Dashboard',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'RuleScan Field Force',
                          style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.textTertiary),
                    tooltip: 'Switch Role / Sign Out',
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      role == 'admin' ? 'Nodal Officer' : 'Field Officer',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.white70, size: 14),
                          SizedBox(width: 6),
                          Text('Offline Mode Active', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Title
              const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),

              // Action Grid - 2x2
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.document_scanner_outlined,
                      label: 'New Scan',
                      subtitle: 'OCR Inspection',
                      color: AppTheme.primaryBlue,
                      bgColor: AppTheme.primaryBlueLight,
                      onTap: () async {
                        await _ensureLocationPermission();
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraOcrPage(searchText: '')));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.image_outlined,
                      label: 'Upload',
                      subtitle: 'E-commerce',
                      color: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFF3E8FF),
                      onTap: () => _uploadScreenshot(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.qr_code_scanner,
                      label: 'Barcode',
                      subtitle: 'Quick ID',
                      color: const Color(0xFFEA580C),
                      bgColor: const Color(0xFFFFF7ED),
                      onTap: () async {
                        await _ensureLocationPermission();
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BarcodePage()));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.history,
                      label: 'History',
                      subtitle: 'Past Scans',
                      color: AppTheme.passGreen,
                      bgColor: AppTheme.passGreenLight,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sync Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.pendingAmberLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: AppTheme.pendingAmber, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sync Data', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          Text('Upload offline inspections', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Starting Background Sync...')),
                        );
                        String result = await SyncService.syncOfflineData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result), duration: const Duration(seconds: 5)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sync'),
                    ),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
          ],
        ),
      ),
    );
  }
}
