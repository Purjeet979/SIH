import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'review_page.dart';
import 'ocr_data.dart';

class CameraOcrPage extends StatefulWidget {
  final String searchText;
  final String? barcode;

  const CameraOcrPage({super.key, required this.searchText, this.barcode});

  @override
  State<CameraOcrPage> createState() => _CameraOcrPageState();
}

class _CameraOcrPageState extends State<CameraOcrPage> {
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
        ResolutionPreset.medium, // Reduced to prevent OCR native crash/freeze
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
        _status = 'Ready to scan. Point at the label.';
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
      _status = 'Capturing & Analyzing... Please hold still.';
    });

    String? tempFilePath;
    try {
      // 1. Take a picture
      final XFile file = await _cameraController!.takePicture();
      tempFilePath = file.path;

      // 2. Run Google ML Kit Text Recognition (Latin first to prevent model-download crash)
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(file.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String allText = recognizedText.text;
      
      List<OcrBlock> blocks = recognizedText.blocks.map((b) => OcrBlock(
        text: b.text,
        boundingBox: b.boundingBox,
        lines: b.lines.map((l) => OcrLine(
          text: l.text,
          boundingBox: l.boundingBox
        )).toList(),
      )).toList();

      textRecognizer.close();
      
      if (mounted) {
        // 3. Navigate directly to Review Page
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => ReviewPage(ocrText: allText, imagePath: tempFilePath, barcode: widget.barcode, ocrBlocks: blocks))
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
        title: const Text('Capture Label'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator()),
          
          // Status text overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCameraInitialized && !_isProcessing
          ? FloatingActionButton.large(
              onPressed: _captureAndAnalyze,
              backgroundColor: Colors.white,
              child: const Icon(Icons.camera_alt, color: Colors.black, size: 40),
            )
          : null,
    );
  }
}
