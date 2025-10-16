import 'package:flutter/material.dart';

class ForgotPasswordFormFields extends StatefulWidget {
  final TextEditingController emailController;
  final String? Function(String?)? validateEmail;

  const ForgotPasswordFormFields({
    super.key,
    required this.emailController,
    this.validateEmail,
  });

  @override
  State<ForgotPasswordFormFields> createState() => _ForgotPasswordFormFieldsState();
}

class _ForgotPasswordFormFieldsState extends State<ForgotPasswordFormFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email field
        _buildInputField(
          controller: widget.emailController,
          hint: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.green.shade400,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}