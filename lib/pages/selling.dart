import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class SellingPage extends StatefulWidget {
  @override
  _SellingPageState createState() => _SellingPageState();
}

class _SellingPageState extends State<SellingPage> {

  File? _mainImage;
  List<File?> _additionalImages = [null, null, null, null];
  final ImagePicker _picker = ImagePicker();

  /// Controllers for input fields
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  /// Dropdown values
  String? _selectedLocation;
  String? _selectedCategory;
  final List<String> _locations = ["Purdue University", "Other Campus"];
  final List<String> _categories = ["Tops", "Bottoms", "Shoes", "Bags", "Accessories"];



  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = Uuid().v4(); // Generate a unique filename
      Reference ref = FirebaseStorage.instance.ref().child('item_images/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); // Get the image URL
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }


  Future<void> _pickImage(bool isMain, int? index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isMain) {
          _mainImage = File(pickedFile.path);
        } else if (index != null && index < _additionalImages.length) {
          _additionalImages[index] = File(pickedFile.path);
        }
      });
    }
  }


  Future<void> _submitItem() async {
    if (_brandController.text.isEmpty || _priceController.text.isEmpty || _selectedCategory == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    // Upload main image
    String? mainImageUrl;
    if (_mainImage != null) {
      mainImageUrl = await _uploadImage(_mainImage!);
    }

    // Upload additional images
    List<String> additionalImageUrls = [];
    for (File? image in _additionalImages) {
      if (image != null) {
        String? url = await _uploadImage(image);
        if (url != null) {
          additionalImageUrls.add(url);
        }
      }
    }

    await FirebaseFirestore.instance.collection('items').add({
      'brand': _brandController.text,
      'condition': _conditionController.text,
      'size': _sizeController.text,
      'color': _colorController.text,
      'style': _styleController.text,
      'location': _selectedLocation,
      'category': _selectedCategory,
      'price': double.parse(_priceController.text),
      'imageUrl': mainImageUrl ?? ''
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Item listed successfully!")),
    );

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4F1E3),
        title: Text(
          'Selling',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Image Upload Section
              Row(
                children: [
                  /// Expanded First Image Box
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage(true, null),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _mainImage == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40),
                                    Text(
                                      "Take a photo or upload\nfrom your library.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_mainImage!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  /// 2x2 Grid of Additional Images
                  Column(
                    children: [
                      Row(
                        children: List.generate(2, (index) {
                          return _buildSmallImageBox(index);
                        }),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: List.generate(2, (index) {
                          return _buildSmallImageBox(index + 2);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              /// Input Fields Section
              Text('DESCRIPTION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildTextField('Brand', _brandController),
              _buildTextField('Condition', _conditionController),
              _buildTextField('Size', _sizeController),
              _buildTextField('Color', _colorController),
              _buildTextField('Style', _styleController),

              SizedBox(height: 20),

              Text('INFO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildDropdownField('Location', _locations, _selectedLocation, (value) {
                setState(() {
                  _selectedLocation = value;
                });
              }),
              _buildDropdownField('Category', _categories, _selectedCategory, (value) {
                setState(() {
                  _selectedCategory = value;
                });
              }),
              _buildPriceField('Item Price', _priceController),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitItem, child: Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the small image boxes in a 2x2 grid
  Widget _buildSmallImageBox(int index) {
    return GestureDetector(
      onTap: () => _pickImage(false, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _additionalImages[index] == null
              ? Icon(Icons.add_a_photo, size: 25)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_additionalImages[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }

  /// Builds a text input field
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// Builds a dropdown menu field
  Widget _buildDropdownField(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            onChanged: onChanged,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Builds a price input field
  Widget _buildPriceField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixText: '\$',
        ),
      ),
    );
  }
}