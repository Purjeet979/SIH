import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndSharePdf(Map<String, dynamic> inspection) async {
    final pdf = pw.Document();

    final String cat = (inspection['category'] ?? 'Unknown').toString().replaceAll('_', ' ').toUpperCase();
    final String time = inspection['timestamp']?.toString() ?? 'N/A';
    final double lat = inspection['latitude'] ?? 0.0;
    final double lng = inspection['longitude'] ?? 0.0;
    final String violations = inspection['violations'] ?? '';
    final String barcode = inspection['barcode'] ?? 'None';
    final String? imagePath = inspection['image_path'];
    
    final int vCount = violations.isEmpty ? 0 : violations.split(',').length;

    pw.ImageProvider? evidenceImage;
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        final imageBytes = await file.readAsBytes();
        evidenceImage = pw.MemoryImage(imageBytes);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('LEGAL METROLOGY INSPECTION REPORT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('RuleScan App', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    ]
                  )
                ),
                pw.SizedBox(height: 20),
                
                // Metadata Section
                pw.Text('INSPECTION DETAILS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                pw.Divider(),
                pw.Text('Report ID: #${inspection['id']}'),
                pw.Text('Date & Time: $time'),
                pw.Text('Officer ID: OFFICER_001'),
                pw.Text('Location (GPS): $lat, $lng'),
                pw.SizedBox(height: 10),
                
                // Product Section
                pw.Text('PRODUCT IDENTIFICATION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                pw.Divider(),
                pw.Text('Category: $cat'),
                pw.Text('Barcode ID: $barcode'),
                pw.SizedBox(height: 10),

                // Compliance Section
                pw.Text('COMPLIANCE STATUS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                pw.Divider(),
                pw.Text(
                  vCount == 0 ? 'STATUS: COMPLIANT (0 Flags)' : 'STATUS: NON-COMPLIANT ($vCount Flags)',
                  style: pw.TextStyle(
                    fontSize: 14, 
                    fontWeight: pw.FontWeight.bold, 
                    color: vCount == 0 ? PdfColors.green700 : PdfColors.red700
                  )
                ),
                if (vCount > 0) ...[
                  pw.SizedBox(height: 8),
                  pw.Text('Missing/Violated Rules:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(violations.replaceAll(',', '\n')),
                ],
                pw.SizedBox(height: 20),

                // Evidence Image
                if (evidenceImage != null) ...[
                  pw.Text('PHOTOGRAPHIC EVIDENCE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Image(evidenceImage, height: 250, fit: pw.BoxFit.contain)
                  )
                ] else ...[
                  pw.Text('No photographic evidence provided.', style: const pw.TextStyle(color: PdfColors.grey)),
                ],
                
                pw.Spacer(),
                pw.Divider(),
                pw.Center(child: pw.Text('Generated securely via RuleScan Mobile App', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)))
              ],
            ),
          );
        },
      ),
    );

    // Share or Print the document using Printing package
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'inspection_report_${inspection['id']}.pdf',
    );
  }
}
