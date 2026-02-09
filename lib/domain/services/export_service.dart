import 'dart:typed_data';

import 'package:bp_monitor/domain/entities/patient_entity.dart';
import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generates PDF and CSV exports of reading data.
class ExportService {
  const ExportService();

  /// Generate a CSV string from readings.
  String generateCsv(List<ReadingEntity> readings) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final rows = <List<dynamic>>[
      [
        'Date',
        'Systolic',
        'Diastolic',
        'Pulse',
        'Category',
        'Quality',
        'Notes',
      ],
      ...readings.map(
        (r) => [
          dateFormat.format(r.takenAt),
          r.systolic,
          r.diastolic,
          r.pulse ?? '',
          r.bpCategory.name,
          r.measurementQuality?.name ?? '',
          r.notes ?? '',
        ],
      ),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  /// Generate a PDF report as bytes.
  Future<Uint8List> generatePdf({
    required PatientEntity patient,
    required List<ReadingEntity> readings,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'BP Report – ${patient.displayName}',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated: ${DateFormat.yMMMd().format(DateTime.now())}',
          ),
          pw.Text('Readings: ${readings.length}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headers: [
              'Date',
              'SYS',
              'DIA',
              'Pulse',
              'Category',
            ],
            data: readings
                .map(
                  (r) => [
                    dateFormat.format(r.takenAt),
                    '${r.systolic}',
                    '${r.diastolic}',
                    r.pulse?.toString() ?? '-',
                    r.bpCategory.name,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
