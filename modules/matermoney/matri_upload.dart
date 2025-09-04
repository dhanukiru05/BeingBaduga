import 'dart:convert';
import 'dart:io';
import 'package:beingbaduga/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MatriUpload extends StatefulWidget {
  final User user;
  final int packageId;

  const MatriUpload({
    Key? key,
    required this.user,
    required this.packageId,
  }) : super(key: key);

  @override
  _MatriUploadState createState() => _MatriUploadState();
}

class _MatriUploadState extends State<MatriUpload> {
  // Main color for icons, etc.
  final Color iconColor = const Color.fromARGB(255, 186, 18, 63);

  // API endpoint for your server
  final String apiUrl = 'https://beingbaduga.com/being_baduga/upload_matri.php';

  // Text controllers for form fields
  final fullNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final emailController = TextEditingController();
  final hattyNameController = TextEditingController();
  final occupationController = TextEditingController();
  final salaryController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final expectationsController = TextEditingController();
  final dobController = TextEditingController();

  // Additional fields
  final degreeController = TextEditingController();
  final streamController = TextEditingController();
  final workingAtController = TextEditingController();

  // Cloudinary-uploaded image URLs
  String? profilePhotoUrl;
  String? aadharPanDlUrl;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Drop-down fields
  String? selectedSeemai;
  String? selectedGender;
  String? selectedSmokeDrink;
  String? selectedDivorce;
  String? selectedAgirBusiness;

  // Editing ID (for update mode)
  int? editingMatrimonyId;

  // Options for drop-down
  final List<String> seemaiOptions = [
    'THODHANAADU',
    'MEKKUNAADU',
    'PORANGADU',
    'KUNDHENAADU',
  ];
  final List<String> genderOptions = ['male', 'female', 'other'];
  final List<String> smokeDrinkOptions = ['yes', 'no'];
  final List<String> divorceOptions = ['yes', 'no'];
  final List<String> agirBusinessOptions = ['yes', 'no'];

  // Matrimony list from server
  List<Map<String, dynamic>> uploadedMatrimonies = [];

  // Loading indicator
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUploadedMatrimonies();
  }

  @override
  void dispose() {
    // Dispose text controllers
    fullNameController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    emailController.dispose();
    hattyNameController.dispose();
    occupationController.dispose();
    salaryController.dispose();
    heightController.dispose();
    weightController.dispose();
    expectationsController.dispose();
    dobController.dispose();
    degreeController.dispose();
    streamController.dispose();
    workingAtController.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------------------
  //                               BUILD WIDGET
  //----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Matrimony Upload',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFBE1744),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.syncAlt, color: Colors.white),
            onPressed: _fetchUploadedMatrimonies,
            tooltip: 'Refresh List',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo (circle)
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Show photo if available, else a default user icon
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: profilePhotoUrl != null
                              ? NetworkImage(profilePhotoUrl!)
                              : null,
                          child: profilePhotoUrl == null
                              ? Icon(
                                  FontAwesomeIcons.userCircle,
                                  color: iconColor.withOpacity(0.6),
                                  size: 60,
                                )
                              : null,
                        ),

                        // Camera icon overlay to pick photo
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickProfilePhoto,
                            child: Container(
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                FontAwesomeIcons.camera,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Remove profile button if an image is selected
                  if (profilePhotoUrl != null)
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            profilePhotoUrl = null;
                          });
                        },
                        icon: Icon(FontAwesomeIcons.trash,
                            color: iconColor, size: 16),
                        label: Text(
                          'Remove Profile Photo',
                          style: TextStyle(
                            color: iconColor,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Header: Add or Edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editingMatrimonyId != null
                            ? 'Edit Matrimony'
                            : 'Add a New Matrimony',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                      if (editingMatrimonyId != null)
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.times,
                              color: Color(0xFFBE1744)),
                          onPressed: _clearForm,
                          tooltip: 'Cancel Editing',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form fields
                  _buildTextField(
                    controller: fullNameController,
                    labelText: 'Full Name',
                    icon: FontAwesomeIcons.user,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: fatherNameController,
                    labelText: 'Father\'s Name',
                    icon: FontAwesomeIcons.userTie,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: motherNameController,
                    labelText: 'Mother\'s Name',
                    icon: FontAwesomeIcons.userNurse,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: emailController,
                    labelText: 'Email',
                    icon: FontAwesomeIcons.envelope,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    label: 'Gender',
                    currentValue: selectedGender,
                    options: genderOptions,
                    iconData: FontAwesomeIcons.transgender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: hattyNameController,
                    labelText: 'Hatty Name',
                    icon: FontAwesomeIcons.building,
                  ),
                  const SizedBox(height: 16),

                  _buildSeemaiDropdownField(
                    label: 'Seemai',
                    currentValue: selectedSeemai,
                    options: seemaiOptions,
                    iconData: FontAwesomeIcons.mapMarkedAlt,
                    onChanged: (value) {
                      setState(() {
                        selectedSeemai = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: occupationController,
                    labelText: 'Occupation',
                    icon: FontAwesomeIcons.briefcase,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: salaryController,
                    labelText: 'Salary',
                    icon: FontAwesomeIcons.dollarSign,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: heightController,
                    labelText: 'Height (cm)',
                    icon: FontAwesomeIcons.rulerVertical,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: weightController,
                    labelText: 'Weight (kg)',
                    icon: FontAwesomeIcons.weight,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    label: 'Smoke/Drink',
                    currentValue: selectedSmokeDrink,
                    options: smokeDrinkOptions,
                    iconData: FontAwesomeIcons.smoking,
                    onChanged: (value) {
                      setState(() {
                        selectedSmokeDrink = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    label: 'Divorce',
                    currentValue: selectedDivorce,
                    options: divorceOptions,
                    iconData: FontAwesomeIcons.ban,
                    onChanged: (value) {
                      setState(() {
                        selectedDivorce = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    label: 'Agir Business',
                    currentValue: selectedAgirBusiness,
                    options: agirBusinessOptions,
                    iconData: FontAwesomeIcons.businessTime,
                    onChanged: (value) {
                      setState(() {
                        selectedAgirBusiness = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Degree
                  _buildTextField(
                    controller: degreeController,
                    labelText: 'Degree',
                    icon: FontAwesomeIcons.graduationCap,
                  ),
                  const SizedBox(height: 16),

                  // Stream
                  _buildTextField(
                    controller: streamController,
                    labelText: 'Stream',
                    icon: FontAwesomeIcons.book,
                  ),
                  const SizedBox(height: 16),

                  // Working At
                  _buildTextField(
                    controller: workingAtController,
                    labelText: 'Working At',
                    icon: FontAwesomeIcons.building,
                  ),
                  const SizedBox(height: 16),

                  // Expectations
                  _buildTextField(
                    controller: expectationsController,
                    labelText: 'Expectations',
                    icon: FontAwesomeIcons.commentDots,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // DOB with an Indian-format date picker
                  InkWell(
                    onTap: _pickDate,
                    child: IgnorePointer(
                      child: _buildTextField(
                        controller: dobController,
                        labelText: 'Date of Birth (DD/MM/YYYY)',
                        icon: FontAwesomeIcons.calendarAlt,
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Aadhaar/PAN/DL picker & preview
                  Text(
                    'Aadhaar/PAN/DL Image:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickAadhaarPanDl,
                        icon: const Icon(FontAwesomeIcons.upload),
                        label: const Text('Choose Image'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // White text
                          backgroundColor: iconColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (aadharPanDlUrl != null)
                        Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: iconColor),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(aadharPanDlUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (aadharPanDlUrl != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              aadharPanDlUrl = null;
                            });
                          },
                          icon: Icon(FontAwesomeIcons.trash,
                              color: iconColor, size: 16),
                          label: Text(
                            'Remove Aadhaar/PAN/DL',
                            style: TextStyle(
                              color: iconColor,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),

                  // Upload or Update button (white text)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: editingMatrimonyId == null
                          ? _uploadMatrimony
                          : _updateMatrimony,
                      icon: Icon(
                        editingMatrimonyId == null
                            ? FontAwesomeIcons.upload
                            : FontAwesomeIcons.edit,
                        color: Colors.white,
                      ),
                      label: Text(
                        editingMatrimonyId == null
                            ? 'Upload Matrimony'
                            : 'Update Matrimony',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // White text
                        backgroundColor: iconColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Uploaded Matrimonies header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uploaded Matrimonies',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.syncAlt,
                          color: Colors.white,
                        ),
                        onPressed: _fetchUploadedMatrimonies,
                        tooltip: 'Refresh List',
                        color: iconColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List of uploaded matrimonies
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
                    child: uploadedMatrimonies.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No matrimonies uploaded yet. Please upload your matrimony.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: uploadedMatrimonies.length,
                            itemBuilder: (context, index) {
                              final matrimony = uploadedMatrimonies[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    FontAwesomeIcons.user,
                                    color: iconColor,
                                    size: 30,
                                  ),
                                  title: Text(
                                    matrimony['full_name'] ?? 'Unknown Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Father: ${matrimony['father_name'] ?? 'N/A'}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        'Mother: ${matrimony['mother_name'] ?? 'N/A'}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        'Seemai: ${matrimony['seemai'] ?? 'N/A'}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        'DOB: ${matrimony['dob'] ?? 'N/A'}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Edit
                                      IconButton(
                                        icon: const Icon(
                                          FontAwesomeIcons.edit,
                                          color: Color(0xFFBE1744),
                                        ),
                                        onPressed: () => _editMatrimony(index),
                                        tooltip: 'Edit Matrimony',
                                      ),
                                      // Delete
                                      IconButton(
                                        icon: const Icon(
                                          FontAwesomeIcons.trashAlt,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteMatrimony(index),
                                        tooltip: 'Delete Matrimony',
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

  //----------------------------------------------------------------------------
  //                       INDIAN-FORMAT DATE PICKER
  //----------------------------------------------------------------------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 01, 01),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'OK',
      builder: (context, child) {
        // You can customize the style here if you want
        return child!;
      },
    );

    if (picked != null) {
      // Format: DD/MM/YYYY
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        dobController.text = formatted;
      });
    }
  }

  //----------------------------------------------------------------------------
  //                           FORM BUILD HELPERS
  //----------------------------------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: iconColor),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    );
  }

  // For Seemai, we remove the icon from the dropdown items
  Widget _buildSeemaiDropdownField({
    required String label,
    required String? currentValue,
    required List<String> options,
    required IconData iconData,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option.toUpperCase()), // No icon here
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(iconData, color: iconColor),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? currentValue,
    required List<String> options,
    required IconData iconData,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option.toUpperCase()), // No row icon
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(iconData, color: iconColor),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    );
  }

  //----------------------------------------------------------------------------
  //                          IMAGE PICK & UPLOAD
  //----------------------------------------------------------------------------
  Future<void> _pickProfilePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final url = await _uploadToCloudinary(file);
        setState(() {
          profilePhotoUrl = url;
        });
      }
    } catch (e) {
      _showMessage('Error picking profile photo: $e');
    }
  }

  Future<void> _pickAadhaarPanDl() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final url = await _uploadToCloudinary(file);
        setState(() {
          aadharPanDlUrl = url;
        });
      }
    } catch (e) {
      _showMessage('Error picking Aadhar/PAN/DL photo: $e');
    }
  }

  /// Uploads a single file to Cloudinary with your cloud name & unsigned preset
  Future<String> _uploadToCloudinary(File file) async {
    setState(() {
      _isLoading = true;
    });

    // Use your actual Cloud Name & unsigned Upload Preset
    final cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/dyjx95lts/image/upload';

    final request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = "profile"
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonData = jsonDecode(responseData.body);
        final secureUrl = jsonData['secure_url'];

        setState(() {
          _isLoading = false;
        });

        return secureUrl;
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception(
            'Cloudinary Error (status ${response.statusCode}). Check your cloud name & upload preset.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  //----------------------------------------------------------------------------
  //                     FETCH, UPLOAD, UPDATE, DELETE
  //----------------------------------------------------------------------------
  Future<void> _fetchUploadedMatrimonies() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'get_matripost',
          'user_id': widget.user.id.toString(),
          'package_id': widget.packageId.toString(),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            uploadedMatrimonies = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          _showMessage('API Error: ${data['message']}');
        }
      } else {
        _showMessage('Network Error: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error fetching matrimonies: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadMatrimony() async {
    final fullName = fullNameController.text.trim();
    final fatherName = fatherNameController.text.trim();
    final motherName = motherNameController.text.trim();
    final email = emailController.text.trim();
    final hattyName = hattyNameController.text.trim();
    final occupation = occupationController.text.trim();
    final salary = salaryController.text.trim();
    final height = heightController.text.trim();
    final weight = weightController.text.trim();
    final expectations = expectationsController.text.trim();
    final dob = dobController.text.trim();
    final degree = degreeController.text.trim();
    final stream = streamController.text.trim();
    final workingAt = workingAtController.text.trim();

    // Basic checks
    if (fullName.isEmpty ||
        fatherName.isEmpty ||
        motherName.isEmpty ||
        email.isEmpty ||
        selectedGender == null ||
        hattyName.isEmpty ||
        selectedSeemai == null ||
        occupation.isEmpty ||
        salary.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        selectedSmokeDrink == null ||
        selectedDivorce == null ||
        selectedAgirBusiness == null ||
        dob.isEmpty ||
        degree.isEmpty ||
        stream.isEmpty ||
        workingAt.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    if (profilePhotoUrl == null) {
      _showMessage('Please pick a Profile Photo.');
      return;
    }

    if (aadharPanDlUrl == null) {
      _showMessage('Please pick an Aadhar/PAN/DL image.');
      return;
    }

    // Validate email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showMessage('Invalid email address.');
      return;
    }
    // Validate DOB (DD/MM/YYYY) -> Convert or handle as needed for your server
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dob)) {
      _showMessage('DOB must be in DD/MM/YYYY format.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'upload_matripost',
          'user_id': widget.user.id.toString(),
          'package_id': widget.packageId.toString(),

          'full_name': fullName,
          'father_name': fatherName,
          'mother_name': motherName,
          'email': email,
          'gender': selectedGender!,
          'hatty_name': hattyName,
          'seemai': selectedSeemai!,
          'occupation': occupation,
          'salary': salary,
          'height': height,
          'weight': weight,
          'smoke_drink': selectedSmokeDrink!,
          'divorce': selectedDivorce!,
          'agir_business': selectedAgirBusiness!,
          'aadhaar_pan_dl': aadharPanDlUrl!,
          'profile_photo_url': profilePhotoUrl!,
          'expectations': expectations,

          // The date user typed is DD/MM/YYYY, if server needs YYYY-MM-DD,
          // you'd parse and reformat here. For now we just send as is:
          'dob': dob,
          'degree': degree,
          'stream': stream,
          'working_at': workingAt,

          'status': 'active',
          'archive_status': 'not_archived',
          'created_by': widget.user.id.toString(),
          'modified_by': widget.user.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _fetchUploadedMatrimonies();
          _showMessage('Matrimony uploaded successfully!');
          _clearForm();
        } else {
          _showMessage(data['message']);
        }
      } else {
        _showMessage('Failed to upload. Code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error uploading matrimony: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMatrimony() async {
    if (editingMatrimonyId == null) return;

    final fullName = fullNameController.text.trim();
    final fatherName = fatherNameController.text.trim();
    final motherName = motherNameController.text.trim();
    final email = emailController.text.trim();
    final hattyName = hattyNameController.text.trim();
    final occupation = occupationController.text.trim();
    final salary = salaryController.text.trim();
    final height = heightController.text.trim();
    final weight = weightController.text.trim();
    final expectations = expectationsController.text.trim();
    final dob = dobController.text.trim();
    final degree = degreeController.text.trim();
    final stream = streamController.text.trim();
    final workingAt = workingAtController.text.trim();

    if (fullName.isEmpty ||
        fatherName.isEmpty ||
        motherName.isEmpty ||
        email.isEmpty ||
        selectedGender == null ||
        hattyName.isEmpty ||
        selectedSeemai == null ||
        occupation.isEmpty ||
        salary.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        selectedSmokeDrink == null ||
        selectedDivorce == null ||
        selectedAgirBusiness == null ||
        dob.isEmpty ||
        degree.isEmpty ||
        stream.isEmpty ||
        workingAt.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    if (profilePhotoUrl == null) {
      _showMessage('Please pick a Profile Photo.');
      return;
    }

    if (aadharPanDlUrl == null) {
      _showMessage('Please pick an Aadhar/PAN/DL image.');
      return;
    }

    // Validate email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showMessage('Invalid email address.');
      return;
    }
    // Validate DOB (DD/MM/YYYY)
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dob)) {
      _showMessage('DOB must be in DD/MM/YYYY format.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'update_matripost',
          'id': editingMatrimonyId.toString(),
          'user_id': widget.user.id.toString(),
          'package_id': widget.packageId.toString(),
          'full_name': fullName,
          'father_name': fatherName,
          'mother_name': motherName,
          'email': email,
          'gender': selectedGender!,
          'hatty_name': hattyName,
          'seemai': selectedSeemai!,
          'occupation': occupation,
          'salary': salary,
          'height': height,
          'weight': weight,
          'smoke_drink': selectedSmokeDrink!,
          'divorce': selectedDivorce!,
          'agir_business': selectedAgirBusiness!,
          'aadhaar_pan_dl': aadharPanDlUrl!,
          'profile_photo_url': profilePhotoUrl!,
          'expectations': expectations,
          'dob': dob,
          'degree': degree,
          'stream': stream,
          'working_at': workingAt,
          'modified_by': widget.user.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _fetchUploadedMatrimonies();
          _showMessage('Matrimony updated successfully!');
          _clearForm();
        } else {
          _showMessage(data['message']);
        }
      } else {
        _showMessage('Failed to update. Code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error updating matrimony: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMatrimony(int index) async {
    final matrimonyId = uploadedMatrimonies[index]['id'];
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'delete_matripost',
          'id': matrimonyId.toString(),
          'user_id': widget.user.id.toString(),
          'package_id': widget.packageId.toString(),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _fetchUploadedMatrimonies();
          _showMessage('Matrimony deleted successfully.');
        } else {
          _showMessage(data['message']);
        }
      } else {
        _showMessage('Failed to delete. Code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error deleting matrimony: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //----------------------------------------------------------------------------
  //                         EDIT & CLEAR FORM
  //----------------------------------------------------------------------------
  void _editMatrimony(int index) {
    final matrimony = uploadedMatrimonies[index];
    setState(() {
      editingMatrimonyId = matrimony['id'];

      fullNameController.text = matrimony['full_name'] ?? '';
      fatherNameController.text = matrimony['father_name'] ?? '';
      motherNameController.text = matrimony['mother_name'] ?? '';
      emailController.text = matrimony['email'] ?? '';
      hattyNameController.text = matrimony['hatty_name'] ?? '';
      occupationController.text = matrimony['occupation'] ?? '';
      salaryController.text = (matrimony['salary'] ?? '').toString();
      heightController.text = (matrimony['height'] ?? '').toString();
      weightController.text = (matrimony['weight'] ?? '').toString();
      expectationsController.text = matrimony['expectations'] ?? '';
      dobController.text = matrimony['dob'] ?? '';
      degreeController.text = matrimony['degree'] ?? '';
      streamController.text = matrimony['stream'] ?? '';
      workingAtController.text = matrimony['working_at'] ?? '';

      // Normalize dropdown values
      final newGender = (matrimony['gender'] ?? '').toLowerCase();
      selectedGender = genderOptions.contains(newGender) ? newGender : null;

      final newSeemai = (matrimony['seemai'] ?? '').toUpperCase();
      selectedSeemai = seemaiOptions.contains(newSeemai) ? newSeemai : null;

      final newSmokeDrink = (matrimony['smoke_drink'] ?? '').toLowerCase();
      selectedSmokeDrink =
          smokeDrinkOptions.contains(newSmokeDrink) ? newSmokeDrink : null;

      final newDivorce = (matrimony['divorce'] ?? '').toLowerCase();
      selectedDivorce = divorceOptions.contains(newDivorce) ? newDivorce : null;

      final newAgirBusiness = (matrimony['agir_business'] ?? '').toLowerCase();
      selectedAgirBusiness = agirBusinessOptions.contains(newAgirBusiness)
          ? newAgirBusiness
          : null;

      // Existing images
      profilePhotoUrl = matrimony['profile_photo_url'];
      aadharPanDlUrl = matrimony['aadhaar_pan_dl'];
    });
  }

  void _clearForm() {
    setState(() {
      editingMatrimonyId = null;

      fullNameController.clear();
      fatherNameController.clear();
      motherNameController.clear();
      emailController.clear();
      hattyNameController.clear();
      occupationController.clear();
      salaryController.clear();
      heightController.clear();
      weightController.clear();
      expectationsController.clear();
      dobController.clear();
      degreeController.clear();
      streamController.clear();
      workingAtController.clear();

      selectedGender = null;
      selectedSeemai = null;
      selectedSmokeDrink = null;
      selectedDivorce = null;
      selectedAgirBusiness = null;

      profilePhotoUrl = null;
      aadharPanDlUrl = null;
    });
  }

  //----------------------------------------------------------------------------
  //                         SHOW SNACKBAR MESSAGE
  //----------------------------------------------------------------------------
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
