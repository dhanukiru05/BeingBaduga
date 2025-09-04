import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController hattyNameController = TextEditingController();
  final TextEditingController seemaiController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController familyStatusController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController smokingDrinkingController =
      TextEditingController();
  final TextEditingController divorceController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController streamController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController agricultureOrBusinessController =
      TextEditingController();

  final String profileImageUrl =
      'https://res.cloudinary.com/dordpmvpm/image/upload/v1725135496/z9nzcj2ijq6gira5ceuw.jpg'; // Example profile image

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40), // Space for visual adjustment
              // Profile Picture Section with Camera Icon
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(profileImageUrl),
                      backgroundColor: Colors.transparent,
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // Handle profile picture change
                      },
                      color: theme.primaryColor,
                      iconSize: 30,
                      padding: EdgeInsets.all(12),
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Profile Section Header
              _buildSectionHeader('Personal Information', theme),
              _buildCard([
                _buildTextField('Full Name', nameController, theme),
                _buildTextField('Age', ageController, theme),
                _buildTextField('Description', descriptionController, theme),
                _buildTextField('Gender', genderController, theme),
                _buildTextField('Height (in cm)', heightController, theme),
                _buildTextField('Location', locationController, theme),
              ], theme),
              SizedBox(height: 20),
              // Family Information Section
              _buildSectionHeader('Family Information', theme),
              _buildCard([
                _buildTextField("Father's Name", fatherNameController, theme),
                _buildTextField("Mother's Name", motherNameController, theme),
                _buildTextField('Hatty Name', hattyNameController, theme),
                _buildTextField('Seemai', seemaiController, theme),
                _buildTextField('Family Status', familyStatusController, theme),
              ], theme),
              SizedBox(height: 20),
              // Professional Information Section
              _buildSectionHeader('Professional Information', theme),
              _buildCard([
                _buildTextField('Occupation', occupationController, theme),
                _buildTextField('Salary', salaryController, theme),
                _buildTextField('Degree', degreeController, theme),
                _buildTextField('Stream', streamController, theme),
                _buildTextField('Company', companyController, theme),
                _buildTextField('Agriculture or Business',
                    agricultureOrBusinessController, theme),
              ], theme),
              SizedBox(height: 40),
              // Save Button
              ElevatedButton.icon(
                onPressed: () {
                  // Add save functionality here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile Saved!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.primaryColor, // Use theme's primary color
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.save, color: Colors.white),
                label: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Header Builder
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Custom Card Builder to group fields
  Widget _buildCard(List<Widget> children, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // Custom TextField builder
  Widget _buildTextField(
      String labelText, TextEditingController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: theme.hintColor, // Use hint color for label
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: theme.primaryColor,
                width: 2.0), // Change border color on focus
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.textTheme.bodyLarge?.color, // Use theme text color
        ),
      ),
    );
  }
}
