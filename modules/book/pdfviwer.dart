import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PDFViewerPage extends StatefulWidget {
  final List<Map<String, dynamic>> books;
  final int currentIndex;

  const PDFViewerPage({
    Key? key,
    required this.books,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPdfPath;
  bool _isLoading = true;
  int _lastStatusCode = 200;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.currentIndex >= widget.books.length) return;

      final book = widget.books[widget.currentIndex];
      final pdfUrl = book['pdf_url'] as String?;

      if (pdfUrl == null || pdfUrl.isEmpty) {
        print('No PDF URL found for this book.');
        setState(() {
          localPdfPath = null;
          _isLoading = false;
        });
        return;
      }

      // Attempt to download PDF from the cloud URL
      final response = await http.get(Uri.parse(pdfUrl));
      _lastStatusCode = response.statusCode;

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/temp_${widget.currentIndex}.pdf');

        await file.writeAsBytes(bytes, flush: true);

        setState(() {
          localPdfPath = file.path;
          _isLoading = false;
        });
      } else {
        print('Failed to load PDF, status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
          localPdfPath = null;
        });
      }
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        _isLoading = false;
        localPdfPath = null;
      });
    }
  }

  // Show next PDF
  void _showNextBook() {
    if (widget.currentIndex < widget.books.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            currentIndex: widget.currentIndex + 1,
            books: widget.books,
          ),
        ),
      );
    }
  }

  // Show prev PDF
  void _showPreviousBook() {
    if (widget.currentIndex > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            currentIndex: widget.currentIndex - 1,
            books: widget.books,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBook = widget.books.isNotEmpty
        ? widget.books[widget.currentIndex]
        : {'title': 'No Book', 'author': 'No Author'};

    final title = currentBook['title'] ?? 'Unknown Title';
    final author = currentBook['author'] ?? 'Unknown Author';

    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer - $title'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: widget.currentIndex > 0 ? _showPreviousBook : null,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      author,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: widget.currentIndex < widget.books.length - 1
                      ? _showNextBook
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (localPdfPath != null
                    ? PDFView(filePath: localPdfPath!)
                    : Center(
                        child: Text(
                          'Failed to load PDF (status: $_lastStatusCode).',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )),
          ),
        ],
      ),
    );
  }
}
