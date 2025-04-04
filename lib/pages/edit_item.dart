import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditItem extends StatefulWidget {
  final DocumentSnapshot item;

  const EditItem({super.key, required this.item});

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  bool saved = false;

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedLocation;
  String? _selectedCategory;
  String? _selectedStatus;

  final List<String> _locations = ["Purdue University", "Other Campus"];
  final List<String> _categories = ["Tops", "Bottoms", "Shoes", "Bags", "Accessories"];
  final List<String> _statuses = ["Available", "Not Available"];

  @override
  void initState() {
    super.initState();
    
    _brandController.text = widget.item['brand'] ?? '';
    _conditionController.text = widget.item['condition'] ?? '';
    _sizeController.text = widget.item['size'] ?? '';
    _colorController.text = widget.item['color'] ?? '';
    _styleController.text = widget.item['style'] ?? '';
    _priceController.text = widget.item['price']?.toString() ?? '';

    _selectedLocation = widget.item['location'];
    _selectedCategory = widget.item['category'];
    _selectedStatus = widget.item['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F1E3),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4F1E3),
        title: Text(
          'Edit Item',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              _buildDropdownField('Status', _statuses, _selectedStatus, (value) {
                setState(() {
                  _selectedStatus = value;
                });
              }),
              _buildPriceField('Item Price', _priceController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveChanges();
                  if (saved) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save")),
            ]
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    if (_brandController.text.isEmpty ||
      _conditionController.text.isEmpty ||
      _sizeController.text.isEmpty ||
      _colorController.text.isEmpty ||
      _styleController.text.isEmpty ||
      _priceController.text.isEmpty ||
      _selectedLocation == null ||
      _selectedCategory == null ||
      _selectedStatus == null) {
        
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields before saving."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    saved = true;
    await FirebaseFirestore.instance.collection('items').doc(widget.item.id).update({
      'brand': _brandController.text,
      'condition': _conditionController.text,
      'size': _sizeController.text,
      'color': _colorController.text,
      'style': _styleController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'location': _selectedLocation,
      'category': _selectedCategory,
      'status': _selectedStatus,
    });

    //Navigator.pop(context);
  }

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