import 'dart:convert';
import 'dart:io';

import 'package:beingbaduga/User_Model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EbookUpload extends StatefulWidget {
  final User user; // User object passed from the previous screen

  const EbookUpload({Key? key, required this.user}) : super(key: key);

  @override
  _EbookUploadState createState() => _EbookUploadState();
}

class _EbookUploadState extends State<EbookUpload> {
  List<Map<String, dynamic>> uploadedBooks = [];

  // Your existing API endpoint for your own server
  final String apiUrl = 'https://beingbaduga.com/being_baduga/upload_books.php';

  // ImageKit details
  // ------------------------------------------------------------------
  // 1) Obtain your PRIVATE key from ImageKit's dashboard
  // 2) This example is for direct client-side upload (not recommended for production)
  final String imageKitPrivateKey = 'private_EyXn3wm88/t2bIK3vDF8vYI2dYc=';
  final String imageKitUploadUrl =
      'https://upload.imagekit.io/api/v1/files/upload';
  // ------------------------------------------------------------------

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final pdfUrlController = TextEditingController();

  int? editingBookIndex; // To keep track of the book being edited

  @override
  void initState() {
    super.initState();
    _fetchUploadedBooks();
  }

  // -------------------- FETCH UPLOADED BOOKS -------------------- //
  Future<void> _fetchUploadedBooks() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'get_books',
          'user_id': widget.user.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            uploadedBooks = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          debugPrint('API Error: ${data['message']}');
        }
      } else {
        debugPrint('Network Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching uploaded books: $e');
    }
  }

  // -------------------- PICK PDF FILE AND UPLOAD TO IMAGEKIT -------------------- //
  Future<void> _pickPDFFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      // We have a PDF file
      final filePath = result.files.single.path;
      if (filePath == null) return;

      final File pdfFile = File(filePath);

      // Now upload this PDF to ImageKit
      final secureUrl = await _uploadToImageKit(pdfFile);
      if (secureUrl != null) {
        setState(() {
          // Put the secure_url into the controller
          pdfUrlController.text = secureUrl;
        });
      }
    }
  }

  // -------------------- UPLOAD PDF TO IMAGEKIT -------------------- //
  Future<String?> _uploadToImageKit(File file) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(imageKitUploadUrl));

      // Add the file field. "fileName" can be set to any name for the uploaded PDF
      request.fields['fileName'] = 'my_uploaded_file.pdf';
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      // Basic Auth with your private key.
      // imageKitPrivateKey should be base64 encoded as 'privateKey:'
      final credentials = base64Encode(utf8.encode('$imageKitPrivateKey:'));
      request.headers['Authorization'] = 'Basic $credentials';

      // If you want to specify a folder in your ImageKit account, you can add:
      // request.fields['folder'] = '/my_pdfs';

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // The ImageKit file URL is typically in responseData['url']
        return responseData['url'] as String?;
      } else {
        debugPrint('ImageKit upload error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading PDF to ImageKit: $e');
      return null;
    }
  }

  // -------------------- UPLOAD BOOK (SEND URL TO DB) -------------------- //
  Future<void> _uploadBook() async {
    final title = titleController.text.trim();
    final author = authorController.text.trim();
    final pdfUrl = pdfUrlController.text.trim();

    if (title.isEmpty || author.isEmpty || pdfUrl.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    // Now we have an ImageKit URL in pdfUrl
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'action': 'upload_book',
        'title': title,
        'author': author,
        'pdf_url': pdfUrl,
        'user_id': widget.user.id.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await _fetchUploadedBooks(); // Refresh the list
        _showMessage('Book uploaded successfully!');
        titleController.clear();
        authorController.clear();
        pdfUrlController.clear();
      } else {
        _showMessage(data['message']);
      }
    } else {
      _showMessage('Failed to upload the book.');
    }
  }

  // -------------------- DELETE BOOK (SET STATUS=OFF) -------------------- //
  Future<void> _deleteBook(int index) async {
    final bookId = uploadedBooks[index]['id'];

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'action': 'update_status',
        'id': bookId.toString(),
        'status': 'off',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await _fetchUploadedBooks();
        _showMessage('Book marked as inactive.');
      } else {
        _showMessage(data['message']);
      }
    } else {
      _showMessage('Failed to update the book status.');
    }
  }

  // -------------------- EDIT BOOK -------------------- //
  void _editBook(int index) {
    final book = uploadedBooks[index];
    titleController.text = book['title'] ?? '';
    authorController.text = book['author'] ?? '';
    pdfUrlController.text = book['pdf_url'] ?? '';
    setState(() {
      editingBookIndex = index;
    });
  }

  // -------------------- UPDATE BOOK -------------------- //
  Future<void> _updateBook() async {
    if (editingBookIndex == null) return;

    final title = titleController.text.trim();
    final author = authorController.text.trim();
    final pdfUrl = pdfUrlController.text.trim();

    if (title.isEmpty || author.isEmpty || pdfUrl.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    final bookId = uploadedBooks[editingBookIndex!]['id'];

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'action': 'update_book',
        'id': bookId.toString(),
        'title': title,
        'author': author,
        'pdf_url': pdfUrl,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await _fetchUploadedBooks();
        _showMessage('Book updated successfully!');
        titleController.clear();
        authorController.clear();
        pdfUrlController.clear();
        setState(() {
          editingBookIndex = null;
        });
      } else {
        _showMessage(data['message']);
      }
    } else {
      _showMessage('Failed to update the book.');
    }
  }

  // -------------------- SNACK BAR MESSAGE -------------------- //
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // -------------------- BUILD UI -------------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- HEADER ----- //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  editingBookIndex != null ? 'Edit Book' : 'Add a New Book',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE1744),
                  ),
                ),
                if (editingBookIndex != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFBE1744)),
                    onPressed: () {
                      setState(() {
                        editingBookIndex = null;
                        titleController.clear();
                        authorController.clear();
                        pdfUrlController.clear();
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // ----- FORM FIELDS ----- //
            Column(
              children: [
                // Book Title
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Book Title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Author
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: 'Author',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // PDF URL (ImageKit URL goes here)
                TextField(
                  controller: pdfUrlController,
                  decoration: InputDecoration(
                    labelText: 'PDF URL',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // PICK PDF FROM DEVICE & UPLOAD
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickPDFFile,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Choose & Upload PDF to ImageKit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Upload/Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        editingBookIndex == null ? _uploadBook : _updateBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE1744),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded
                      ),
                    ),
                    child: Text(
                      editingBookIndex == null ? 'Upload Book' : 'Update Book',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // ----- UPLOADED BOOKS HEADER ----- //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Uploaded Books',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE1744),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFBE1744)),
                  onPressed: _fetchUploadedBooks,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ----- UPLOADED BOOKS LIST ----- //
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: uploadedBooks.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No books uploaded yet. Please upload your books.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: uploadedBooks.length,
                      itemBuilder: (context, index) {
                        final book = uploadedBooks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.book,
                              color: Color(0xFFBE1744),
                              size: 30,
                            ),
                            title: Text(
                              book['title'] ?? 'Unknown Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              book['author'] ?? 'Unknown Author',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit Button
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFFBE1744)),
                                  onPressed: () => _editBook(index),
                                ),
                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteBook(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
