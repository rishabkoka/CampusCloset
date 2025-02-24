import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Complete Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Complete your details or continue \nwith social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const CompleteProfileForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const Text(
                    "By continuing, you confirm that you agree \nwith our Terms and Conditions",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class CompleteProfileForm extends StatelessWidget {
  const CompleteProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          _buildTextField("Enter your first name", "First Name", userIcon),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _buildTextField("Enter your last name", "Last Name", userIcon),
          ),
          _buildTextField("Enter your phone number", "Phone Number", phoneIcon, keyboardType: TextInputType.phone),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _buildTextField("Enter your address", "Address", locationPointIcon),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFF7643),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: const Text("Continue"),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, String label, String icon, {TextInputType? keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.string(icon, height: 20, width: 20),
        ),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFF7643)),
        ),
      ),
    );
  }
}

// Icons
const userIcon = '''<svg>...</svg>''';
const phoneIcon = '''<svg>...</svg>''';
const locationPointIcon = '''<svg>...</svg>''';
