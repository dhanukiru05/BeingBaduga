// lib/pages/ProfilePage.dart

import 'dart:convert';
import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final User user;
  ProfilePage({required this.user});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController,
      _emailController,
      _phoneController,
      _dobController,
      _ageController,
      _genderController;
  bool _isLoading = false, _isPackageLoading = false;
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService.instance;
  List<Package> _packages = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _dobController = TextEditingController(text: widget.user.dob);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _genderController = TextEditingController(text: widget.user.gender);
    _fetchAvailablePackages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> updatedData = {
        'user_id': widget.user.id,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'gender': _genderController.text.trim(),
      };
      try {
        bool success = await _userService.updateUserProfile(updatedData);
        if (success) {
          setState(() {
            widget.user.name = _nameController.text.trim();
            widget.user.email = _emailController.text.trim();
            widget.user.phone = _phoneController.text.trim();
            widget.user.dob = _dobController.text.trim();
            widget.user.gender = _genderController.text.trim();
            widget.user.age = _calculateAge(DateTime.parse(widget.user.dob));
            _ageController.text = widget.user.age.toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAvailablePackages() async {
    setState(() {
      _isPackageLoading = true;
    });
    final url =
        Uri.parse('https://beingbaduga.com/being_baduga/check_categories.php');
    try {
      final response =
          await http.post(url, body: {'user_id': widget.user.id.toString()});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List services = data['services'];
        setState(() {
          _packages = services
              .map((item) => Package.fromJson(item))
              .where((pkg) => pkg.packageStatus.toLowerCase() == 'available')
              .toList();
        });
      }
    } catch (_) {}
    setState(() {
      _isPackageLoading = false;
    });
  }

  int _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) age--;
    return age;
  }

  Future<void> _selectDate() async {
    DateTime initialDate =
        DateTime.tryParse(_dobController.text) ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData(
          primaryColor: Color(0xFFBE1744),
          colorScheme: ColorScheme.light(primary: Color(0xFFBE1744)),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        widget.user.age = _calculateAge(pickedDate);
        _ageController.text = widget.user.age.toString();
      });
      _fetchAvailablePackages();
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFFEC407A)),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      ),
      validator: validator,
    );
  }

  String _getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return 'https://res.cloudinary.com/dyjx95lts/image/upload/v1751862233/thrulqtwx1eyotiikdhd.jpg';
      case 'matrimony':
        return 'https://res.cloudinary.com/dyjx95lts/image/upload/v1751862212/j5kjzmaemjmxbxofvlni.jpg';
      case 'ebooks':
        return 'https://res.cloudinary.com/dyjx95lts/image/upload/v1751862144/ucdi9zy46u99pkagttga.jpg';
      default:
        return 'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg';
    }
  }

  int _remainingDays(String endDate) {
    try {
      DateTime end = DateTime.parse(endDate);
      return end.difference(DateTime.now()).inDays;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFCE4EC),
        appBar: AppBar(
          title: Text('${widget.user.name}\'s Profile'),
          centerTitle: true,
          backgroundColor: Color(0xFFBE1744),
          actions: [
            IconButton(
                icon: Icon(Icons.save),
                onPressed: _saveChanges,
                tooltip: 'Save Profile'),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFFBE1744)))
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Profile',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333))),
                        SizedBox(height: 5),
                        Text('Manage your account information',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF333333).withOpacity(0.6))),
                        SizedBox(height: 25),
                        Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5))
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Name',
                                icon: Icons.person,
                                controller: _nameController,
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your name'
                                    : null,
                              ),
                              SizedBox(height: 15),
                              _buildTextField(
                                label: 'Email',
                                icon: Icons.email,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please enter your email';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value))
                                    return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              _buildTextField(
                                label: 'Phone Number',
                                icon: Icons.phone,
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please enter your phone number';
                                  if (!RegExp(r'^\d{10}$').hasMatch(value))
                                    return 'Please enter a valid 10-digit phone number';
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              _buildTextField(
                                label: 'Date of Birth',
                                icon: Icons.calendar_today,
                                controller: _dobController,
                                readOnly: true,
                                onTap: _selectDate,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please select your date of birth';
                                  try {
                                    DateTime.parse(value);
                                  } catch (_) {
                                    return 'Please enter a valid date';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              _buildTextField(
                                label: 'Age',
                                icon: Icons.cake,
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                value: _genderController.text.isNotEmpty
                                    ? _genderController.text
                                    : null,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: Color(0xFFEC407A)),
                                  labelText: 'Gender',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 15),
                                ),
                                items: ['Male', 'Female', 'Other']
                                    .map((gender) => DropdownMenuItem(
                                        value: gender, child: Text(gender)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _genderController.text = value!;
                                  });
                                },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please select your gender'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                        Text('Available Packages',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333))),
                        SizedBox(height: 10),
                        _isPackageLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFBE1744)))
                            : _packages.isEmpty
                                ? Text('No available packages.',
                                    style: TextStyle(color: Colors.grey))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _packages.length,
                                    itemBuilder: (context, index) {
                                      final pkg = _packages[index];
                                      return Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        elevation: 3,
                                        child: Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 150,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        _getCategoryImage(
                                                            pkg.categoryName)),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(pkg.categoryName,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    SizedBox(height: 5),
                                                    Text(pkg.packageName,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                    SizedBox(height: 5),
                                                    Text(pkg.description,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700])),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.timer,
                                                            size: 16,
                                                            color: Colors.grey),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            'Duration: ${pkg.duration} days',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey[
                                                                        700])),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 16,
                                                            color: Colors.grey),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            'Ends on: ${pkg.serviceEndDate}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.today,
                                                            size: 16,
                                                            color: Colors.grey),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            'Days left: ${_remainingDays(pkg.serviceEndDate)}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),
                )));
  }
}

class Package {
  final String id;
  final String categoryName;
  final String packageName;
  final String description;
  final int duration;
  final String serviceStartDate;
  final String serviceEndDate;
  final String packageStatus;

  Package({
    required this.id,
    required this.categoryName,
    required this.packageName,
    required this.description,
    required this.duration,
    required this.serviceStartDate,
    required this.serviceEndDate,
    required this.packageStatus,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['package_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? 'Other',
      packageName: json['package_name']?.toString() ?? 'N/A',
      description: json['description']?.toString() ?? '',
      duration: json['duration'] != null
          ? int.tryParse(json['duration'].toString()) ?? 0
          : 0,
      serviceStartDate: json['service_start_date']?.toString() ?? '',
      serviceEndDate: json['service_end_date']?.toString() ?? '',
      packageStatus: json['package_status']?.toString() ?? 'Unavailable',
    );
  }

  num? get price => null;
}
