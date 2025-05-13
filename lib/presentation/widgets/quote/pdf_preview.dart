// lib/presentation/widgets/quote/pdf_preview.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfPreview extends StatelessWidget {
  final String pdfUrl;
  final bool isLoading;
  final VoidCallback? onReload;

  const PdfPreview({
    Key? key,
    required this.pdfUrl,
    this.isLoading = false,
    this.onReload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Generating PDF...'),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.picture_as_pdf,
            size: 72.0,
            color: Colors.red,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'PDF Generated',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Your PDF has been created and is ready to view.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: () => _openPdf(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open PDF'),
          ),
          if (onReload != null) ...[
            const SizedBox(height: 8.0),
            TextButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate PDF'),
            ),
          ],
        ],
      ),
    );
  }

  void _openPdf(BuildContext context) async {
    final uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
      );
    }
  }
}