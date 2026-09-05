import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'camera_ocr_page.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key});

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _status = 'Initializing camera...';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _status = 'No camera available');
        return;
      }

      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.medium, 
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
        _status = 'Ready. Point at a Barcode and Tap Capture.';
      });
    } catch (e) {
      setState(() => _status = 'Camera init failed: $e');
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _status = 'Scanning Barcode...';
    });

    try {
      final XFile file = await _cameraController!.takePicture();
      
      final barcodeScanner = BarcodeScanner();
      final inputImage = InputImage.fromFilePath(file.path);
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      
      String extractedBarcode = '';
      if (barcodes.isNotEmpty) {
        extractedBarcode = barcodes.first.displayValue ?? barcodes.first.rawValue ?? '';
      }
      barcodeScanner.close();
      
      if (mounted) {
        if (extractedBarcode.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barcode Scanned! Now scan the text label.')),
          );
        }
        
        // CRITICAL FIX: Dispose camera BEFORE navigating so the next page can initialize it without hardware locks!
        await _cameraController?.dispose();
        _cameraController = null;
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => CameraOcrPage(searchText: '', barcode: extractedBarcode))
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator()),
          
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _status,
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCameraInitialized && !_isProcessing
          ? FloatingActionButton.extended(
              onPressed: _captureAndAnalyze,
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              icon: const Icon(Icons.qr_code_scanner, size: 24),
              label: const Text('Capture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          : null,
    );
  }
}
