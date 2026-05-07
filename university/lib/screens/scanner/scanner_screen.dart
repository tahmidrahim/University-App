import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';

enum ScanMode { single, batch }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<File> _images = [];
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  ScanMode _currentMode = ScanMode.single;
  final TextEditingController _nameController = TextEditingController();

  final Color primaryDark = const Color(0xFF0F172A);
  final Color accentBlue = const Color(0xFF3B82F6);

  Future<void> _capture(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (file == null) return;

    setState(() {
      if (_currentMode == ScanMode.single) _images.clear();
      _images.add(File(file.path));
      _pdfBytes = null;
    });

    if (_currentMode == ScanMode.single) {
      await _generatePdf(silent: true);
      _showPreviewSheet();
    }
  }

  Future<void> _generatePdf({bool silent = false}) async {
    if (_images.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final pdf = pw.Document();
      for (var f in _images) {
        final img = pw.MemoryImage(await f.readAsBytes());
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (c) =>
                pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain)),
          ),
        );
      }
      _pdfBytes = await pdf.save();
      _nameController.text = "Scan_${DateTime.now().millisecondsSinceEpoch}";
      if (!silent) _showPreviewSheet();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToDevice() async {
    if (_pdfBytes == null) return;

    setState(() => _isLoading = true);

    try {
      // For file_picker ^8.0.0+ - bytes parameter is required
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Lab Report',
        fileName: '${_nameController.text}.pdf',
        bytes: _pdfBytes, // THIS IS REQUIRED for v8+
      );

      if (outputFile != null) {
        if (mounted) {
          Navigator.pop(context);
          _showSnackbar("Saved successfully!", Colors.green);
        }
      }
    } catch (e) {
      _showSnackbar("Export failed: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPreviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Document Name",
                  suffixText: ".pdf",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PdfPreview(
                    build: (f) => _pdfBytes!,
                    useActions: false,
                    canChangePageFormat: false,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _exportToDevice,
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "DOWNLOAD",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => Printing.sharePdf(
                      bytes: _pdfBytes!,
                      filename: '${_nameController.text}.pdf',
                    ),
                    icon: const Icon(Icons.share),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      minimumSize: const Size(55, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Document Scanner",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        foregroundColor: primaryDark,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SegmentedButton<ScanMode>(
              segments: const [
                ButtonSegment(
                  value: ScanMode.single,
                  label: Text("Single"),
                  icon: Icon(Icons.description),
                ),
                ButtonSegment(
                  value: ScanMode.batch,
                  label: Text("Multiple"),
                  icon: Icon(Icons.auto_stories),
                ),
              ],
              selected: {_currentMode},
              onSelectionChanged: (s) => setState(() {
                _currentMode = s.first;
                _images.clear();
                _pdfBytes = null;
              }),
            ),
          ),
          Expanded(child: _buildMainWorkspace()),
          _buildBottomActionArea(),
        ],
      ),
    );
  }

  Widget _buildMainWorkspace() {
    if (_images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_enhance_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text("No pages scanned", style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 8),
            Text(
              "Tap + to add pages",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _images.length,
      itemBuilder: (c, i) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
              image: DecorationImage(
                image: FileImage(_images[i]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _images.removeAt(i)),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _capture(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  minimumSize: const Size(60, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _capture(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    "CAPTURE PAGE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_currentMode == ScanMode.batch && _images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _generatePdf(),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text("FINALIZE BATCH (${_images.length})"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
