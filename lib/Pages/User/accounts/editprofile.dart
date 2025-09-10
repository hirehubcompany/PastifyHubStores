import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app color.dart';

class Editprofiles extends StatefulWidget {
  const Editprofiles({super.key});

  @override
  State<Editprofiles> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofiles> {
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _city = '';
  String _profilePicUrl = '';

  bool _isLoading = false;

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() ?? {};
          setState(() {
            _fullName = data['fullName'] ?? '';
            _email = data['email'] ?? '';
            _phone = data['phone'] ?? '';
            _address = data['address'] ?? '';
            _city = data['city'] ?? '';
            _profilePicUrl = data['profileImage'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfilePicture(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('${user.uid}.jpg');

      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading profile picture: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? imageUrl = _profilePicUrl;
        if (_selectedImage != null) {
          final uploadedUrl = await _uploadProfilePicture(_selectedImage!);
          if (uploadedUrl != null) {
            imageUrl = uploadedUrl;
          }
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fullName': _fullName,
          'email': _email,
          'phone': _phone,
          'address': _address,
          'city': _city,
          'profileImage': imageUrl,
          'updatedAt': Timestamp.now(),
        });

        setState(() {
          _profilePicUrl = imageUrl ?? _profilePicUrl;
          _selectedImage = null; // optional: keep selected image cleared
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Widget _buildTextField(
      String label,
      String value,
      IconData icon,
      Function(String) onChanged,
      FocusNode focusNode,
      FocusNode? nextFocus, {
        TextInputType inputType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        keyboardType: inputType,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.backgroundLight,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
        textInputAction:
        nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
        },
        validator: (value) =>
        value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _cityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture Section
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_profilePicUrl.isNotEmpty
                          ? NetworkImage(_profilePicUrl)
                          : null) as ImageProvider?,
                      child: _selectedImage == null && _profilePicUrl.isEmpty
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tap to change profile picture",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Edit Your Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Update your details below",
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Full Name', _fullName, Icons.person,
                          (val) => _fullName = val, _nameFocusNode, _emailFocusNode),
                  _buildTextField('Email', _email, Icons.email,
                          (val) => _email = val, _emailFocusNode, _phoneFocusNode,
                      inputType: TextInputType.emailAddress),
                  _buildTextField('Phone Number', _phone, Icons.phone,
                          (val) => _phone = val, _phoneFocusNode, _addressFocusNode,
                      inputType: TextInputType.phone),
                  _buildTextField('Address', _address, Icons.location_on,
                          (val) => _address = val, _addressFocusNode, _cityFocusNode),
                  _buildTextField('City', _city, Icons.location_city,
                          (val) => _city = val, _cityFocusNode, null),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save Changes',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveProfile,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
