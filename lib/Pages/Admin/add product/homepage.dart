import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // General fields
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _callNumberCtrl = TextEditingController();
  bool _isPopular = false;

  // Category/Subcategory
  String? _selectedCategory;
  String? _selectedSubcategory;
  final Map<String, List<String>> _categoriesAndSubcategories = {
    'Mobile Phones and Tablets': ['Mobile Phones', 'Accessories for Phone', 'Smart Watches', 'Tablets'],
    'Electronics': ['Laptops and Computer', 'Audio and Equipments', 'Computer Accessories', 'Headphones', 'Softwares', 'Networking Products'],
    'Beauty and Health Care': ['Oral Care', 'Body Care', 'Fragrances'],
    'Fashion': ['Kids', 'Adults'],
    'Services': ['Rental', 'Education', 'Cleaning', 'I.T', 'Photography and Video Graphy'],
  };

  // Subcategory-specific spec controllers
  final Map<String, TextEditingController> _specCtrls = {
    'condition': TextEditingController(),
    'model': TextEditingController(),
    'internalStorage': TextEditingController(),
    'ram': TextEditingController(),
    'color': TextEditingController(),
    'operatingSystem': TextEditingController(),
    'type': TextEditingController(),
    'speakerConnectivity': TextEditingController(),
    'connectivity': TextEditingController(),
    'processor': TextEditingController(),
    'storageCapacity': TextEditingController(),
    'storageType': TextEditingController(),
    'graphicCard': TextEditingController(),
    'numberOfCores': TextEditingController(),
    'name': TextEditingController(),
    'platform': TextEditingController(),
    'version': TextEditingController(),
    'formatDownload': TextEditingController(),
    'numberOfLanPoints': TextEditingController(),
    'maxLanSpeed': TextEditingController(),
    'flavor': TextEditingController(),
    'ingredients': TextEditingController(),
    'features': TextEditingController(),
    'volume': TextEditingController(),
    'gender': TextEditingController(),
    'size': TextEditingController(),
    'specialization': TextEditingController(),
    'Name': TextEditingController(),
    'duration': TextEditingController(),
  };

  // Images: exactly 4
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedImages = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descriptionCtrl.dispose();
    _whatsappCtrl.dispose();
    _callNumberCtrl.dispose();
    for (final c in _specCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // UI helpers
  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  Future<void> _pickImage() async {
    if (_pickedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exactly 4 images are required.')),
      );
      return;
    }
    final XFile? img =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() => _pickedImages.add(img));
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  // Build spec map based on category and subcategory
  Map<String, dynamic> _buildSpecifications() {
    final specs = <String, dynamic>{};
    if (_selectedSubcategory == null) return specs;

    switch (_selectedSubcategory) {
      case 'Mobile Phones':
        return {
          'condition': _specCtrls['condition']!.text.trim(),
          'model': _specCtrls['model']!.text.trim(),
          'internalStorage': _specCtrls['internalStorage']!.text.trim(),
          'ram': _specCtrls['ram']!.text.trim(),
          'color': _specCtrls['color']!.text.trim(),
          'operatingSystem': _specCtrls['operatingSystem']!.text.trim(),
        };
      case 'Accessories for Phone':
        return {
          'condition': _specCtrls['condition']!.text.trim(),
          'type': _specCtrls['type']!.text.trim(),
          'color': _specCtrls['color']!.text.trim(),
        };
      case 'Smart Watches':
        return {
          'condition': _specCtrls['condition']!.text.trim(),
          'type': _specCtrls['type']!.text.trim(),
          'color': _specCtrls['color']!.text.trim(),
        };
      case 'Tablets':
        return {
          'condition': _specCtrls['condition']!.text.trim(),
          'model': _specCtrls['model']!.text.trim(),
          'internalStorage': _specCtrls['internalStorage']!.text.trim(),
          'ram': _specCtrls['ram']!.text.trim(),
          'color': _specCtrls['color']!.text.trim(),
          'operatingSystem': _specCtrls['operatingSystem']!.text.trim(),
        };
      case 'Laptops and Computer':
        return {
          'condition': _specCtrls['condition']!.text.trim(),
          'model': _specCtrls['model']!.text.trim(),
          'ram': _specCtrls['ram']!.text.trim(),
          'color': _specCtrls['color']!.text.trim(),
          'operatingSystem': _specCtrls['operatingSystem']!.text.trim(),
          'type': _specCtrls['type']!.text.trim(),
          'processor': _specCtrls['processor']!.text.trim(),
          'storageCapacity': _specCtrls['storageCapacity']!.text.trim(),
          'storageType': _specCtrls['storageType']!.text.trim(),
          'graphicCard': _specCtrls['graphicCard']!.text.trim(),
          'numberOfCores': int.tryParse(_specCtrls['numberOfCores']!.text.trim()) ?? _specCtrls['numberOfCores']!.text.trim(),
        };
      case 'Audio and Equipments':
        final connText = _specCtrls['speakerConnectivity']!.text.trim();
        final connectivity = connText.isEmpty
            ? []
            : connText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        return {
          'condition': _specCtrls['condition']!.text.trim(),
          'type': _specCtrls['type']!.text.trim(),
          'speakerConnectivity': connectivity,
        };
      case 'Computer Accessories':
        return {
          'type': _specCtrls['type']!.text.trim(),
        };
      case 'Headphones':
        final connText = _specCtrls['connectivity']!.text.trim();
        final connectivity = connText.isEmpty
            ? []
            : connText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        return {
          'type': _specCtrls['type']!.text.trim(),
          'condition': _specCtrls['condition']!.text.trim(),
          'connectivity': connectivity,
        };
      case 'Softwares':
        return {
          'name': _specCtrls['name']!.text.trim(),
          'platform': _specCtrls['platform']!.text.trim(),
          'version': _specCtrls['version']!.text.trim(),
          'type': _specCtrls['type']!.text.trim(),
          'formatDownload': _specCtrls['formatDownload']!.text.trim(),
        };
      case 'Networking Products':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'model': _specCtrls['model']!.text.trim(),
          'numberOfLanPoints': int.tryParse(_specCtrls['numberOfLanPoints']!.text.trim()) ?? _specCtrls['numberOfLanPoints']!.text.trim(),
          'condition': _specCtrls['condition']!.text.trim(),
          'maxLanSpeed': int.tryParse(_specCtrls['maxLanSpeed']!.text.trim()) ?? _specCtrls['maxLanSpeed']!.text.trim(),
        };
      case 'Oral Care':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'flavor': _specCtrls['flavor']!.text.trim(),
          'ingredients': _specCtrls['ingredients']!.text.trim(),
          'features': _specCtrls['features']!.text.trim(),
        };
      case 'Body Care':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'volume': _specCtrls['volume']!.text.trim(),
          'gender': _specCtrls['gender']!.text.trim(),
        };
      case 'Fragrances':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'volume': _specCtrls['volume']!.text.trim(),
          'gender': _specCtrls['gender']!.text.trim(),
        };
      case 'Kids':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'gender': _specCtrls['gender']!.text.trim(),
          'size': _specCtrls['size']!.text.trim(),
          'color': _specCtrls['color']!.text.trim(),
        };
      case 'Adults':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'gender': _specCtrls['gender']!.text.trim(),
          'size': _specCtrls['size']!.text.trim(),
          'color': _specCtrls['color']!.text.trim(),
        };
      case 'Rental':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'specialization': _specCtrls['specialization']!.text.trim(),
          'Name': _specCtrls['Name']!.text.trim(),
          'duration': _specCtrls['duration']!.text.trim(),
        };
      case 'Education':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'specialization': _specCtrls['specialization']!.text.trim(),
          'Name': _specCtrls['Name']!.text.trim(),
          'duration': _specCtrls['duration']!.text.trim(),
        };
      case 'Cleaning':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'specialization': _specCtrls['specialization']!.text.trim(),
          'Name': _specCtrls['Name']!.text.trim(),
          'duration': _specCtrls['duration']!.text.trim(),
        };
      case 'I.T':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'specialization': _specCtrls['specialization']!.text.trim(),
          'Name': _specCtrls['Name']!.text.trim(),
          'duration': _specCtrls['duration']!.text.trim(),
        };
      case 'Photography and Video Graphy':
        return {
          'type': _specCtrls['type']!.text.trim(),
          'specialization': _specCtrls['specialization']!.text.trim(),
          'Name': _specCtrls['Name']!.text.trim(),
          'duration': _specCtrls['duration']!.text.trim(),
        };
      default:
        return {};
    }
  }

  // Validate spec inputs for the chosen subcategory
  String? _validateSpecs() {
    if (_selectedSubcategory == null || _selectedSubcategory!.isEmpty) {
      return 'Please choose a subcategory';
    }

    final needed = <String>[];
    switch (_selectedSubcategory) {
      case 'Mobile Phones':
        needed.addAll(['condition', 'model', 'internalStorage', 'ram', 'color', 'operatingSystem']);
        break;
      case 'Accessories for Phone':
        needed.addAll(['condition', 'type', 'color']);
        break;
      case 'Smart Watches':
        needed.addAll(['condition', 'type', 'color']);
        break;
      case 'Tablets':
        needed.addAll(['condition', 'model', 'internalStorage', 'ram', 'color', 'operatingSystem']);
        break;
      case 'Laptops and Computer':
        needed.addAll(['condition', 'model', 'ram', 'color', 'operatingSystem', 'type', 'processor', 'storageCapacity', 'storageType', 'graphicCard', 'numberOfCores']);
        break;
      case 'Audio and Equipments':
        needed.addAll(['condition', 'type', 'speakerConnectivity']);
        break;
      case 'Computer Accessories':
        needed.addAll(['type']);
        break;
      case 'Headphones':
        needed.addAll(['type', 'condition', 'connectivity']);
        break;
      case 'Softwares':
        needed.addAll(['name', 'platform', 'version', 'type', 'formatDownload']);
        break;
      case 'Networking Products':
        needed.addAll(['type', 'model', 'numberOfLanPoints', 'condition', 'maxLanSpeed']);
        break;
      case 'Oral Care':
        needed.addAll(['type', 'flavor', 'ingredients', 'features']);
        break;
      case 'Body Care':
        needed.addAll(['type', 'volume', 'gender']);
        break;
      case 'Fragrances':
        needed.addAll(['type', 'volume', 'gender']);
        break;
      case 'Kids':
        needed.addAll(['type', 'gender', 'size', 'color']);
        break;
      case 'Adults':
        needed.addAll(['type', 'gender', 'size', 'color']);
        break;
      case 'Rental':
        needed.addAll(['type', 'specialization', 'Name', 'duration']);
        break;
      case 'Education':
        needed.addAll(['type', 'specialization', 'Name', 'duration']);
        break;
      case 'Cleaning':
        needed.addAll(['type', 'specialization', 'Name', 'duration']);
        break;
      case 'I.T':
        needed.addAll(['type', 'specialization', 'Name', 'duration']);
        break;
      case 'Photography and Video Graphy':
        needed.addAll(['type', 'specialization', 'Name', 'duration']);
        break;
    }

    for (final k in needed) {
      if (_specCtrls[k]!.text.trim().isEmpty) return 'Please fill $k';
    }
    return null;
  }

  Future<List<String>> _uploadImages(String productId) async {
    final storage = FirebaseStorage.instance;
    final List<String> urls = [];
    for (int i = 0; i < _pickedImages.length; i++) {
      final XFile x = _pickedImages[i];
      final ref = storage.ref().child('products/$productId/image_$i.jpg');
      UploadTask task;
      if (kIsWeb) {
        final bytes = await x.readAsBytes();
        task = ref.putData(bytes);
      } else {
        task = ref.putFile(File(x.path));
      }
      final snap = await task.whenComplete(() {});
      final url = await snap.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_selectedSubcategory == null || _selectedSubcategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subcategory')),
      );
      return;
    }

    if (_pickedImages.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly 4 images')),
      );
      return;
    }

    final specErr = _validateSpecs();
    if (specErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(specErr)),
      );
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price')),
      );
      return;
    }

    final stock = int.tryParse(_stockCtrl.text.trim());
    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid stock')),
      );
      return;
    }

    final whatsapp = int.tryParse(_whatsappCtrl.text.trim());
    if (whatsapp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid WhatsApp number')),
      );
      return;
    }

    final callNumber = int.tryParse(_callNumberCtrl.text.trim());
    if (callNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid call number')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final productId = _nameCtrl.text.trim().replaceAll(RegExp(r'[.#$/\[\]]'), '_');
      final docRef = FirebaseFirestore.instance
          .collection('All Products')
          .doc(productId);

      final imageUrls = await _uploadImages(productId);
      final now = Timestamp.now();
      final specifications = _buildSpecifications();

      final data = <String, dynamic>{
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'productName': _nameCtrl.text.trim(),
        'brand': _brandCtrl.text.trim(),
        'price': price,
        'stock': stock,
        'description': _descriptionCtrl.text.trim(),
        'whatsapp': whatsapp,
        'callNumber': callNumber,
        'popular': _isPopular,
        'images': imageUrls,
        'specifications': specifications,
        'createdAt': now,
        'updatedAt': now,
      };

      await docRef.set(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        // Removed Navigator.pop to keep the form active
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSubcategorySpecForm() {
    if (_selectedSubcategory == null) return const SizedBox.shrink();

    switch (_selectedSubcategory) {
      case 'Mobile Phones':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Model', _specCtrls['model']!),
            const SizedBox(height: 8),
            _specField('Internal Storage', _specCtrls['internalStorage']!),
            const SizedBox(height: 8),
            _specField('RAM', _specCtrls['ram']!),
            const SizedBox(height: 8),
            _specField('Color', _specCtrls['color']!),
            const SizedBox(height: 8),
            _specField('Operating System', _specCtrls['operatingSystem']!),
          ],
        );
      case 'Accessories for Phone':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Color', _specCtrls['color']!),
          ],
        );
      case 'Smart Watches':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Color', _specCtrls['color']!),
          ],
        );
      case 'Tablets':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Model', _specCtrls['model']!),
            const SizedBox(height: 8),
            _specField('Internal Storage', _specCtrls['internalStorage']!),
            const SizedBox(height: 8),
            _specField('RAM', _specCtrls['ram']!),
            const SizedBox(height: 8),
            _specField('Color', _specCtrls['color']!),
            const SizedBox(height: 8),
            _specField('Operating System', _specCtrls['operatingSystem']!),
          ],
        );
      case 'Laptops and Computer':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Model', _specCtrls['model']!),
            const SizedBox(height: 8),
            _specField('RAM', _specCtrls['ram']!),
            const SizedBox(height: 8),
            _specField('Color', _specCtrls['color']!),
            const SizedBox(height: 8),
            _specField('Operating System', _specCtrls['operatingSystem']!),
            const SizedBox(height: 8),
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Processor', _specCtrls['processor']!),
            const SizedBox(height: 8),
            _specField('Storage Capacity', _specCtrls['storageCapacity']!),
            const SizedBox(height: 8),
            _specField('Storage Type', _specCtrls['storageType']!),
            const SizedBox(height: 8),
            _specField('Graphic Card', _specCtrls['graphicCard']!),
            const SizedBox(height: 8),
            _specField('Number of Cores', _specCtrls['numberOfCores']!, keyboardType: TextInputType.number),
          ],
        );
      case 'Audio and Equipments':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Speaker Connectivity (comma-separated)', _specCtrls['speakerConnectivity']!),
          ],
        );
      case 'Computer Accessories':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
          ],
        );
      case 'Headphones':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Connectivity (comma-separated)', _specCtrls['connectivity']!),
          ],
        );
      case 'Softwares':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Name', _specCtrls['name']!),
            const SizedBox(height: 8),
            _specField('Platform', _specCtrls['platform']!),
            const SizedBox(height: 8),
            _specField('Version', _specCtrls['version']!),
            const SizedBox(height: 8),
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Format Download', _specCtrls['formatDownload']!),
          ],
        );
      case 'Networking Products':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Model', _specCtrls['model']!),
            const SizedBox(height: 8),
            _specField('Number Of LAN points', _specCtrls['numberOfLanPoints']!, keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            _specField('Condition', _specCtrls['condition']!),
            const SizedBox(height: 8),
            _specField('Max LAN Speed', _specCtrls['maxLanSpeed']!, keyboardType: TextInputType.number),
          ],
        );
      case 'Oral Care':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Flavor', _specCtrls['flavor']!),
            const SizedBox(height: 8),
            _specField('Ingredients', _specCtrls['ingredients']!),
            const SizedBox(height: 8),
            _specField('Features', _specCtrls['features']!),
          ],
        );
      case 'Body Care':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Volume', _specCtrls['volume']!),
            const SizedBox(height: 8),
            _specField('Gender', _specCtrls['gender']!),
          ],
        );
      case 'Fragrances':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Volume', _specCtrls['volume']!),
            const SizedBox(height: 8),
            _specField('Gender', _specCtrls['gender']!),
          ],
        );
      case 'Kids':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Gender', _specCtrls['gender']!),
            const SizedBox(height: 8),
            _specField('Size', _specCtrls['size']!),
            const SizedBox(height: 8),
            _specField('Color', _specCtrls['color']!),
          ],
        );
      case 'Adults':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Gender', _specCtrls['gender']!),
            const SizedBox(height: 8),
            _specField('Size', _specCtrls['size']!),
            const SizedBox(height: 8),
            _specField('Color', _specCtrls['color']!),
          ],
        );
      case 'Rental':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Specialization', _specCtrls['specialization']!),
            const SizedBox(height: 8),
            _specField('Name', _specCtrls['Name']!),
            const SizedBox(height: 8),
            _specField('Duration', _specCtrls['duration']!),
          ],
        );
      case 'Education':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Specialization', _specCtrls['specialization']!),
            const SizedBox(height: 8),
            _specField('Name', _specCtrls['Name']!),
            const SizedBox(height: 8),
            _specField('Duration', _specCtrls['duration']!),
          ],
        );
      case 'Cleaning':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Specialization', _specCtrls['specialization']!),
            const SizedBox(height: 8),
            _specField('Name', _specCtrls['Name']!),
            const SizedBox(height: 8),
            _specField('Duration', _specCtrls['duration']!),
          ],
        );
      case 'I.T':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Specialization', _specCtrls['specialization']!),
            const SizedBox(height: 8),
            _specField('Name', _specCtrls['Name']!),
            const SizedBox(height: 8),
            _specField('Duration', _specCtrls['duration']!),
          ],
        );
      case 'Photography and Video Graphy':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specField('Type', _specCtrls['type']!),
            const SizedBox(height: 8),
            _specField('Specialization', _specCtrls['specialization']!),
            const SizedBox(height: 8),
            _specField('Name', _specCtrls['Name']!),
            const SizedBox(height: 8),
            _specField('Duration', _specCtrls['duration']!),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _specField(String label, TextEditingController ctrl,
      {String? hint, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: _dec(label, hint: hint),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Category
                DropdownButtonFormField<String>(
                  decoration: _dec('Category'),
                  items: _categoriesAndSubcategories.keys
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  value: _selectedCategory,
                  onChanged: (v) {
                    setState(() {
                      _selectedCategory = v;
                      _selectedSubcategory = null; // Reset subcategory
                    });
                  },
                  validator: (v) => (v == null || v.isEmpty) ? 'Select a category' : null,
                ),
                const SizedBox(height: 12),

                // Subcategory
                DropdownButtonFormField<String>(
                  decoration: _dec('Subcategory'),
                  items: _selectedCategory != null
                      ? _categoriesAndSubcategories[_selectedCategory]!
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList()
                      : [],
                  value: _selectedSubcategory,
                  onChanged: (v) {
                    setState(() {
                      _selectedSubcategory = v;
                    });
                  },
                  validator: (v) => (v == null || v.isEmpty) ? 'Select a subcategory' : null,
                ),
                const SizedBox(height: 16),

                // General fields
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _dec('Product Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _brandCtrl,
                  decoration: _dec('Brand'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter brand' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _dec('Price', hint: 'e.g. 899.99'),
                  validator: (v) {
                    final d = double.tryParse(v?.trim() ?? '');
                    if (d == null || d <= 0) return 'Enter valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Stock', hint: 'e.g. 25'),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n < 0) return 'Enter valid stock';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 4,
                  decoration: _dec('Description'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _whatsappCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Whatsapp'),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null) return 'Enter valid WhatsApp number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _callNumberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Call Number'),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null) return 'Enter valid call number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text('Popular'),
                  value: _isPopular,
                  onChanged: (bool value) {
                    setState(() {
                      _isPopular = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Images (exactly 4)', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_pickedImages.length, (i) {
                    final x = _pickedImages[i];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(x.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: InkWell(
                            onTap: () => _removeImage(i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text('${_pickedImages.length}/4 selected', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                // Dynamic specs
                const Text('Specifications', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSubcategorySpecForm(),
                const SizedBox(height: 24),

                // Save
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: _isSaving
                        ? const Text('Saving...')
                        : const Text('Save Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const bool kIsWeb = identical(0, 0.0);