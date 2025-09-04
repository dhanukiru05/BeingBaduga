// BizUpload.dart

import 'dart:convert';
import 'dart:io';
import 'package:beingbaduga/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class BizUpload extends StatefulWidget {
  final User user; // User object passed from the previous screen

  const BizUpload({Key? key, required this.user}) : super(key: key);

  @override
  _BizUploadState createState() => _BizUploadState();
}

class _BizUploadState extends State<BizUpload> {
  // Controllers for form fields
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final photoController = TextEditingController(); // Will store Cloudinary URL
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final serviceController = TextEditingController();

  // List of services added by user
  List<String> services = [];

  // List of previously uploaded profiles
  List<Map<String, dynamic>> uploadedProfiles = [];

  // Are we loading?
  bool _isLoading = false;

  // Editing logic
  int? editingProfileIndex; // Null if not editing

  // API endpoint
  final String apiUrl =
      'https://beingbaduga.com/being_baduga/upload_profiles.php';

  // Cloudinary configuration — same keys/preset used in MatriUpload
  // Update these to match your actual Cloudinary settings
  final String cloudName = 'dyjx95lts';
  final String uploadPreset = 'profile';

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // App bar color
  final Color appBarColor = const Color(0xFFBE1744);

  // Track which label is tapped (for UI focus indication)
  int? tappedLabelIndex;

  @override
  void initState() {
    super.initState();
    _fetchUploadedProfiles();
  }

  // Dispose controllers
  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    photoController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    serviceController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  //                               UI Building
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        // Dismiss keyboard when tapping outside
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            tappedLabelIndex = null;
          });
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (Add or Edit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            editingProfileIndex != null
                                ? 'Edit Profile'
                                : 'Add a New Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: appBarColor,
                            ),
                          ),
                          if (editingProfileIndex != null)
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: appBarColor,
                              onPressed: () {
                                setState(() {
                                  editingProfileIndex = null;
                                  _clearFormFields();
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Business Name
                      _buildTextField(
                        controller: nameController,
                        label: 'Business Name',
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 16),

                      // Business Type
                      _buildTextField(
                        controller: typeController,
                        label: 'Business Type',
                        icon: Icons.business_center,
                      ),
                      const SizedBox(height: 16),

                      // Photo URL field (read-only, filled after Cloudinary upload)
                      _buildTextField(
                        controller: photoController,
                        label: 'Photo URL (auto-filled)',
                        icon: Icons.image,
                        readOnly: true,
                      ),
                      const SizedBox(height: 8),

                      // Button to pick and upload image
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: _pickImageAndUploadToCloudinary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appBarColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.cloud_upload,
                              color: Colors.white),
                          label: const Text(
                            'Upload Image to Cloudinary',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      _buildTextField(
                        controller: addressController,
                        label: 'Address',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildTextField(
                        controller: descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Services
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: serviceController,
                              label: 'Add Service',
                              icon: Icons.add_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appBarColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Display the list of services
                      services.isEmpty
                          ? Container()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border:
                                                Border.all(color: appBarColor),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: TextField(
                                            controller: TextEditingController(
                                              text: services[index],
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) =>
                                                _editService(index, value),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            services.removeAt(index);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 20),

                      // Upload or Update button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: editingProfileIndex == null
                              ? _uploadProfile
                              : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appBarColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            editingProfileIndex == null
                                ? 'Upload Profile'
                                : 'Update Profile',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Uploaded Profiles Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploaded Profiles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: appBarColor,
                            ),
                          ),
                          // Refresh Button
                          IconButton(
                            icon: Icon(Icons.refresh, color: appBarColor),
                            onPressed: _fetchUploadedProfiles,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Uploaded Profiles List
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
                        child: uploadedProfiles.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'No profiles uploaded yet. Please upload your profiles.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: uploadedProfiles.length,
                                itemBuilder: (context, index) {
                                  final profile = uploadedProfiles[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 2,
                                    child: ListTile(
                                      leading: Icon(Icons.business,
                                          color: appBarColor, size: 30),
                                      title: Text(
                                        profile['name'] ?? 'Unknown Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        profile['type'] ?? 'Unknown Type',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Edit Button
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: appBarColor),
                                            onPressed: () =>
                                                _editProfile(index),
                                          ),
                                          // Delete Button
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deleteProfile(index),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        // Optionally, implement viewing detailed profile
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //                         Cloudinary Upload Logic
  // ---------------------------------------------------------------------------
  /// Pick an image from the gallery, then upload to Cloudinary.
  Future<void> _pickImageAndUploadToCloudinary() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return; // no image picked

      final File imageFile = File(pickedFile.path);

      // Upload image to Cloudinary
      final String? uploadedUrl = await _uploadImageToCloudinary(imageFile);
      if (uploadedUrl != null) {
        setState(() {
          photoController.text = uploadedUrl; // Store the secure URL
        });
        _showMessage('Image uploaded successfully!');
      } else {
        _showMessage('Failed to upload image to Cloudinary.');
      }
    } catch (e) {
      _showMessage('Error picking image: $e');
    }
  }

  /// Uploads an image to Cloudinary using [cloudName] & [uploadPreset].
  /// Returns the secure_url on success, or null on failure.
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    final Uri cloudinaryUrl =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    // Prepare multipart request
    var request = http.MultipartRequest('POST', cloudinaryUrl)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    try {
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final responseData = await streamedResponse.stream.bytesToString();
        final Map<String, dynamic> decoded = json.decode(responseData);
        final String secureUrl = decoded['secure_url'];

        setState(() {
          _isLoading = false;
        });
        return secureUrl;
      } else {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Cloudinary upload error: ${streamedResponse.statusCode}');
        return null;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Cloudinary exception: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  //                          Fetch / Upload / Update / Delete
  // ---------------------------------------------------------------------------
  /// Fetch existing profiles from your server for this user
  Future<void> _fetchUploadedProfiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'get_profiles',
          'user_id': widget.user.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            uploadedProfiles = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          _showMessage('API Error: ${data['message']}');
        }
      } else {
        _showMessage('Network Error: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error fetching uploaded profiles: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Upload a new profile with the Cloudinary photo URL
  Future<void> _uploadProfile() async {
    final name = nameController.text.trim();
    final type = typeController.text.trim();
    final photo = photoController.text.trim(); // Cloudinary URL
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();
    final description = descriptionController.text.trim();

    // Validate
    if (name.isEmpty ||
        type.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        address.isEmpty ||
        description.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }
    if (photo.isEmpty) {
      _showMessage('Please upload an image first.');
      return;
    }

    final servicesJson = jsonEncode(services);

    // Default operating hours in JSON
    final operatingHours = jsonEncode([
      {"day": "Monday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Tuesday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Wednesday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Thursday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Friday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Saturday", "hours": "9:00 AM - 3:00 PM"},
      {"day": "Sunday", "hours": "Closed"}
    ]);

    setState(() {
      _isLoading = true;
    });

    try {
      // Send upload request
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'upload_profile',
          'name': name,
          'type': type,
          'photo': photo, // the Cloudinary URL
          'phone': phone,
          'email': email,
          'address': address,
          'description': description,
          'operating_hours': operatingHours,
          'services': servicesJson,
          'user_id': widget.user.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _fetchUploadedProfiles(); // Refresh the list
          _showMessage('Profile uploaded successfully!');
          _clearFormFields();
        } else {
          _showMessage(data['message']);
        }
      } else {
        _showMessage('Failed to upload the profile.');
      }
    } catch (e) {
      _showMessage('Error uploading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Edit an existing profile (fill form fields for editing)
  void _editProfile(int index) {
    final profile = uploadedProfiles[index];
    nameController.text = profile['name'] ?? '';
    typeController.text = profile['type'] ?? '';
    photoController.text = profile['photo'] ?? '';
    phoneController.text = profile['phone'] ?? '';
    emailController.text = profile['email'] ?? '';
    addressController.text = profile['address'] ?? '';
    descriptionController.text = profile['description'] ?? '';
    services = List<String>.from(json.decode(profile['services'] ?? '[]'));

    setState(() {
      editingProfileIndex = index;
    });
  }

  /// Update a profile on the server
  Future<void> _updateProfile() async {
    if (editingProfileIndex == null) return;

    final name = nameController.text.trim();
    final type = typeController.text.trim();
    final photo = photoController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty ||
        type.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        address.isEmpty ||
        description.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }
    if (photo.isEmpty) {
      _showMessage('Please upload an image first.');
      return;
    }

    final servicesJson = jsonEncode(services);

    final profileId = uploadedProfiles[editingProfileIndex!]['business_id'];

    // Default operating hours in JSON (replace if needed)
    final operatingHours = jsonEncode([
      {"day": "Monday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Tuesday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Wednesday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Thursday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Friday", "hours": "8:00 AM - 5:00 PM"},
      {"day": "Saturday", "hours": "9:00 AM - 3:00 PM"},
      {"day": "Sunday", "hours": "Closed"}
    ]);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'update_profile',
          'id': profileId.toString(),
          'name': name,
          'type': type,
          'photo': photo,
          'phone': phone,
          'email': email,
          'address': address,
          'description': description,
          'operating_hours': operatingHours,
          'services': servicesJson,
          'user_id': widget.user.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _fetchUploadedProfiles(); // Refresh the list
          _showMessage('Profile updated successfully!');
          _clearFormFields();
          setState(() {
            editingProfileIndex = null;
          });
        } else {
          _showMessage(data['message']);
        }
      } else {
        _showMessage('Failed to update the profile.');
      }
    } catch (e) {
      _showMessage('Error updating the profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Delete (archive) a profile on the server
  Future<void> _deleteProfile(int index) async {
    final profileId = uploadedProfiles[index]['business_id'];
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'update_status',
          'id': profileId.toString(),
          'user_id': widget.user.id.toString(),
          'status': '1', // marks it as inactive
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            // Remove from local list for instant feedback
            uploadedProfiles.removeAt(index);
          });
          _showMessage('Profile marked as inactive.');
        } else {
          _showMessage(data['message']);
        }
      } else {
        _showMessage('Failed to update the profile status.');
      }
    } catch (e) {
      _showMessage('Error deleting profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  //                              Helper Methods
  // ---------------------------------------------------------------------------
  void _clearFormFields() {
    nameController.clear();
    typeController.clear();
    photoController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    descriptionController.clear();
    services.clear();
    serviceController.clear();
  }

  void _addService() {
    if (serviceController.text.trim().isEmpty) return;
    setState(() {
      services.add(serviceController.text.trim());
      serviceController.clear();
    });
  }

  void _editService(int index, String value) {
    setState(() {
      services[index] = value;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tappedLabelIndex = -1; // reset tapped label
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: appBarColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          readOnly: readOnly,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: tappedLabelIndex != null ? appBarColor : Colors.black,
            ),
            prefixIcon: Icon(icon, color: appBarColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: contentPadding,
          ),
          onTap: () {
            setState(() {
              tappedLabelIndex = -1;
            });
          },
        ),
      ),
    );
  }
}
