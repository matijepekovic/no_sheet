// lib/core/services/pdf_service.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../../data/models/quote.dart';
import '../../data/models/customer.dart';

class PdfService {
  // Format currency
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  // Format date
  String formatDate(DateTime date) {
    final formatter = DateFormat('MM/dd/yyyy');
    return formatter.format(date);
  }

  // Generate PDF for quote
  Future<Uint8List> generateQuotePdf(Quote quote, Customer customer) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Create a PDF theme with custom fonts (optional)
    // final font = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    // final ttf = pw.Font.ttf(font);

    // Business information - would typically come from a settings service
    final businessName = "NoSheet CRM";
    final businessAddress = "123 Main St, Kent, WA 98032";
    final businessPhone = "(555) 123-4567";
    final businessEmail = "contact@nosheetcrm.com";

    // Add pages to the PDF document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          // Header with business info and quote details
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(businessName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(businessAddress),
                    pw.Text('$businessPhone | $businessEmail'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('QUOTE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Quote #: ${quote.id.substring(0, 8)}'),
                    pw.Text('Date: ${formatDate(quote.createdAt)}'),
                    pw.Text('Valid Until: ${formatDate(quote.validUntil)}'),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Quote Title
          pw.Text(
            quote.title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 20),

          // Customer Information
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1, color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CUSTOMER INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Name: ${customer.name}'),
                if (customer.email.isNotEmpty) pw.Text('Email: ${customer.email}'),
                pw.Text('Phone: ${customer.phone}'),
                pw.Text('Address: ${customer.address}'),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Quote Items Table
          pw.Table.fromTextArray(
            border: null,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: ['Item', 'Description', 'Quantity', 'Unit Price', 'Total'],
            data: quote.items.map((item) => [
              item.name,
              item.description,
              item.quantity.toString() + (item.unit != null ? ' ${item.unit}' : ''),
              formatCurrency(item.unitPrice),
              formatCurrency(item.total),
            ]).toList(),
          ),

          pw.SizedBox(height: 10),

          // Totals
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 150,
                      child: pw.Text('Subtotal:'),
                    ),
                    pw.Container(
                      width: 100,
                      child: pw.Text(formatCurrency(quote.subtotal), textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 150,
                      child: pw.Text('Tax (${quote.taxRate}%):'),
                    ),
                    pw.Container(
                      width: 100,
                      child: pw.Text(formatCurrency(quote.taxAmount), textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                if (quote.discount > 0)
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 150,
                        child: pw.Text('Discount:'),
                      ),
                      pw.Container(
                        width: 100,
                        child: pw.Text('-${formatCurrency(quote.discount)}', textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                pw.Divider(),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 150,
                      child: pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      width: 100,
                      child: pw.Text(formatCurrency(quote.total),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Notes
          if (quote.notes != null && quote.notes!.isNotEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1, color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('NOTES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(quote.notes!),
                ],
              ),
            ),

          pw.SizedBox(height: 40),

          // Terms and Signature
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Terms & Conditions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('1. Quote valid until ${formatDate(quote.validUntil)}'),
                  pw.Text('2. Payment terms: Net 30'),
                  pw.Text('3. Prices are subject to change'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Client Acceptance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 180,
                    decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide())
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Signature & Date'),
                ],
              ),
            ],
          ),

          // Footer
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(width: 1, color: PdfColors.grey300))
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Thank you for your business!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );

    // Return PDF document as bytes
    return pdf.save();
  }
}