import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFService {
  Future<void> generateIDCard(Map<String, dynamic> details) async {
    final pdf = pw.Document();

    final starSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#1565C0" d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
</svg>
''';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Stack(
              children: [
                // Main Card Container with Background Pattern
                pw.Container(
                  width: 342.4, // Standard ID-1
                  height: 215.92,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue900, width: 1),
                    borderRadius: pw.BorderRadius.circular(10),
                    color: PdfColors.white,
                    gradient: pw.LinearGradient(
                       begin: pw.Alignment.topLeft,
                       end: pw.Alignment.bottomRight,
                       colors: [PdfColors.blue50, PdfColors.white]
                    )
                  ),
                ),
                
                 // Background Guilloche-like Pattern (Simulated with circles)
                 pw.Positioned(
                   right: -50,
                   bottom: -50,
                   child: pw.Container(
                     width: 200,
                     height: 200,
                     decoration: pw.BoxDecoration(
                       shape: pw.BoxShape.circle,
                       border: pw.Border.all(color: PdfColors.blue100, width: 20),
                     ),
                   ),
                 ),
                 
                 // Card Content
                 pw.Container(
                   width: 342.4,
                   height: 215.92,
                   child: pw.Column(
                     children: [
                       // 1. Header with Emblem and Title
                       pw.Container(
                         height: 45,
                         decoration: const pw.BoxDecoration(
                           color: PdfColors.blue800,
                           borderRadius: pw.BorderRadius.only(topLeft: pw.Radius.circular(9), topRight: pw.Radius.circular(9)),
                         ),
                         child: pw.Row(
                           children: [
                             pw.SizedBox(width: 15),
                             // Simulated Emblem (Star)
                             pw.Container(
                               width: 30,
                               height: 30,
                               decoration: const pw.BoxDecoration(
                                 color: PdfColors.white,
                                 shape: pw.BoxShape.circle,
                               ),
                               padding: const pw.EdgeInsets.all(2),
                               child: pw.Center(child: pw.SvgImage(svg: starSvg)),
                             ),
                             pw.Expanded(
                               child: pw.Center(
                                 child: pw.Column(
                                   mainAxisAlignment: pw.MainAxisAlignment.center,
                                   children: [
                                     pw.Text('JAMHUURIYADDA FEDERAALKA SOOMAALIYA', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                                     pw.Text('FEDERAL REPUBLIC OF SOMALIA', style: pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                                   ]
                                 ),
                               ),
                             ),
                             pw.SizedBox(width: 45), // Balance
                           ]
                         ),
                       ),
                       
                       // 2. Main Body
                       pw.Expanded(
                         child: pw.Padding(
                           padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5), // Reduced vertical padding
                           child: pw.Row(
                             crossAxisAlignment: pw.CrossAxisAlignment.start,
                             children: [
                               // Left Side: Photo & Chip
                               pw.Column(
                                 children: [
                                   pw.SizedBox(height: 5),
                                   pw.Container(
                                     width: 75, // Slightly smaller photo
                                     height: 95,
                                     decoration: pw.BoxDecoration(
                                       border: pw.Border.all(color: PdfColors.grey400),
                                       color: PdfColors.grey100,
                                     ),
                                     child: pw.Center(child: pw.Text('PHOTO', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey))),
                                   ),
                                   pw.SizedBox(height: 6),
                                   // Smart Chip
                                   pw.Container(
                                     width: 35,
                                     height: 25,
                                     decoration: pw.BoxDecoration(
                                       color: PdfColors.amber300,
                                       borderRadius: pw.BorderRadius.circular(4),
                                       border: pw.Border.all(color: PdfColors.amber700),
                                     ),
                                     child: pw.CustomPaint(
                                        painter: (canvas, size) {
                                            canvas.drawRect(0, 8, size.x, 2); 
                                            canvas.drawRect(12, 0, 2, size.y); 
                                        }
                                     ),
                                   ),
                                 ]
                               ),
                               pw.SizedBox(width: 12),
                               
                               // Right Side: Details
                               pw.Expanded(
                                 child: pw.Column(
                                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                                   children: [
                                     pw.Text('NATIONAL ID CARD', style: pw.TextStyle(color: PdfColors.blue800, fontWeight: pw.FontWeight.bold, fontSize: 10)), // Reduced font
                                     pw.Divider(color: PdfColors.blue800, thickness: 1),
                                     pw.SizedBox(height: 2),
                                     
                                     _buildIDDetail('Magaca / Name', details['fullName'] ?? 'N/A'),
                                     pw.SizedBox(height: 3),
                                     
                                     pw.Row(
                                       children: [
                                          pw.Expanded(child: _buildIDDetail('Jinsiga / Sex', details['gender'] ?? 'N/A')),
                                          pw.SizedBox(width: 5),
                                          pw.Expanded(child: _buildIDDetail('Dhalashada / DOB', details['dob'] ?? 'N/A')),
                                       ]
                                     ),
                                     pw.SizedBox(height: 3),
                                     
                                     pw.Row(
                                       children: [
                                          pw.Expanded(child: _buildIDDetail('Goobta Dhalashada / POB', details['placeOfBirth'] ?? 'Mogadishu')),
                                          pw.SizedBox(width: 5),
                                          pw.Expanded(child: _buildIDDetail('Jinsiyadda / Nationality', 'Somali')),
                                       ]
                                     ),
                                     
                                     pw.SizedBox(height: 3),
                                     pw.Row(
                                       children: [
                                         _buildIDDetail('Bixinta / Date of Issue', DateTime.now().toString().split(' ')[0]),
                                         pw.SizedBox(width: 15),
                                         _buildIDDetail('Dhicitaanka / Exp Date', DateTime(DateTime.now().year + 5, DateTime.now().month, DateTime.now().day).toString().split(' ')[0]),
                                       ]
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                       
                       // 3. Footer / MRZ
                       pw.Container(
                         height: 25,
                         width: double.infinity,
                         decoration: const pw.BoxDecoration(
                           color: PdfColors.white,
                           borderRadius: pw.BorderRadius.only(bottomLeft: pw.Radius.circular(9), bottomRight: pw.Radius.circular(9)),
                         ),
                         padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                         child: pw.Row(
                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                           children: [
                             pw.Text(
                               'IDSOM${DateTime.now().year}${DateTime.now().month}<<<<<<<<<<<<<<<',
                               style: pw.TextStyle(font: pw.Font.courier(), fontSize: 10, letterSpacing: 2)
                             ),
                             pw.BarcodeWidget(
                               barcode: pw.Barcode.code128(),
                               data: DateTime.now().millisecondsSinceEpoch.toString().substring(5),
                               width: 80,
                               height: 20,
                               drawText: false,
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'national_id_card.pdf',
    );
  }

  pw.Widget _buildIDDetail(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  Future<void> generateBirthCertificate(Map<String, dynamic> details) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue, width: 4),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Center(child: pw.Text('JAMHUURIYADDA FEDERAALKA SOOMAALIYA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                pw.SizedBox(height: 5),
                pw.Center(child: pw.Text('WASAARADDA ARRIMAHA GUDAHA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('FEDERAL REPUBLIC OF SOMALIA', style: pw.TextStyle(fontSize: 12))),
                pw.Center(child: pw.Text('MINISTRY OF INTERIOR', style: pw.TextStyle(fontSize: 12))),
                pw.SizedBox(height: 20),
                
                // Emblem Placeholder (Optional)
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: const pw.BoxDecoration(
                     shape: pw.BoxShape.circle,
                     color: PdfColors.blue100
                  ),
                  child: pw.Center(child: pw.Text('SO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))
                ),
                
                pw.SizedBox(height: 20),
                pw.Text('SHAHADADA DHALASHADA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 22, color: PdfColors.blue)),
                pw.Text('BIRTH CERTIFICATE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blue)),
                
                pw.SizedBox(height: 40),
                
                // Details Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(150),
                    1: const pw.FlexColumnWidth(),
                  },
                  children: [
                     _buildTableRow('Full Name / Magaca', details['childFullName'] ?? details['fullName'] ?? 'N/A'),
                     _buildTableRow('Date of Birth / T. Dhalashada', details['dob'] ?? 'N/A'),
                     _buildTableRow('Place of Birth / Goobta Dhalashada', details['placeOfBirth'] ?? 'Mogadishu'),
                     _buildTableRow('Sex / Jinsiga', details['gender'] ?? 'N/A'),
                     _buildTableRow('Father\'s Name / Magaca Aabaha', details['fatherName'] ?? 'N/A'),
                     _buildTableRow('Mother\'s Name / Magaca Hooyada', details['motherName'] ?? 'N/A'),
                     _buildTableRow('Date of Issue / Taariikhda Bixinta', DateTime.now().toString().split(' ')[0]),
                     _buildTableRow('Registration No / Tirsiga', DateTime.now().millisecondsSinceEpoch.toString().substring(6)),
                  ]
                ),

                pw.Spacer(),

                // Signature Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                     pw.Column(
                       children: [
                         pw.Container(width: 120, height: 1, color: PdfColors.black),
                         pw.SizedBox(height: 5),
                         pw.Text('Director of Civil Registration'),
                         pw.Text('Agaasimaha Diiwaangelinta'),
                       ]
                     ),
                     pw.Column(
                       children: [
                         pw.Container(width: 80, height: 80, decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey), shape: pw.BoxShape.circle), child: pw.Center(child: pw.Text('SEAL'))),
                       ]
                     ),
                  ]
                ),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'birth_certificate.pdf',
    );
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }
}
