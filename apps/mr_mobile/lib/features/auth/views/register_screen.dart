import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/auth_controller.dart';
import '../../../app/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  String _selectedTerritory = 'T-001';
  bool _agreedToTerms = false;
  bool _showPassword = false;

  static const _territories = [
    _Territory('T-001', 'Mumbai West'),
    _Territory('T-002', 'Mumbai East'),
    _Territory('T-003', 'Delhi North'),
    _Territory('T-004', 'Delhi South'),
    _Territory('T-005', 'Bangalore East'),
    _Territory('T-006', 'Bangalore West'),
    _Territory('T-007', 'Chennai Central'),
    _Territory('T-008', 'Hyderabad North'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Phone must be exactly 10 digits';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least 1 number';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      Get.snackbar(
        'Terms Required',
        'Please agree to the Terms & Conditions to continue.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    _authController.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
      _selectedTerritory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshGradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // ── Header ────────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Color(0xFF4F378A), size: 20),
                      onPressed: () => Get.back(),
                    ),
                    Image.asset('assets/logo.png', width: 32, height: 32),
                  ],
                ),
                const SizedBox(height: 24),

                // Gradient title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4F378A), Color(0xFF008080)],
                  ).createShader(bounds),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join MediVisit Pro to manage your field visits.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF494551),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Form Card ─────────────────────────────────────────────
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _buildLabel('Full Name'),
                      const SizedBox(height: 8),
                      _buildField(
                        controller: _nameController,
                        hint: 'Dr. Ramesh Kumar',
                        icon: Icons.person_outline_rounded,
                        validator: _validateName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildLabel('Email Address'),
                      const SizedBox(height: 8),
                      _buildField(
                        controller: _emailController,
                        hint: 'you@company.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),

                      // Phone
                      _buildLabel('Phone Number'),
                      const SizedBox(height: 8),
                      _buildField(
                        controller: _phoneController,
                        hint: '10-digit mobile number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 20),

                      // Territory
                      _buildLabel('Select Territory'),
                      const SizedBox(height: 8),
                      _buildTerritoryDropdown(),
                      const SizedBox(height: 20),

                      // Password
                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      _buildPasswordField(),
                      const SizedBox(height: 8),

                      // Password strength hint
                      const Text(
                        'Min. 8 characters, 1 uppercase letter, 1 number',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7A7582),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Terms checkbox
                      _buildTermsRow(),
                      const SizedBox(height: 28),

                      // Submit button
                      Obx(() => GradientButton(
                            text: 'Create Account',
                            isLoading: _authController.isLoading.value,
                            onPressed: _submit,
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF494551)),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.login),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF4F378A), Color(0xFF008080)],
                        ).createShader(bounds),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1D1B20),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Color(0xFF1D1B20), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBC4D2), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4F378A), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFCBC4D2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBC4D2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4F378A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
        ),
        errorStyle: const TextStyle(color: Color(0xFFB3261E), fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: !_showPassword,
      style: const TextStyle(color: Color(0xFF1D1B20), fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Min. 8 chars, 1 uppercase, 1 number',
        hintStyle: const TextStyle(color: Color(0xFFCBC4D2), fontSize: 13),
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, color: Color(0xFF4F378A), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: const Color(0xFF7A7582),
            size: 20,
          ),
          onPressed: () => setState(() => _showPassword = !_showPassword),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBC4D2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBC4D2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F378A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
        ),
        errorStyle: const TextStyle(color: Color(0xFFB3261E), fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildTerritoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBC4D2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTerritory,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded,
              color: Color(0xFF4F378A)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          items: _territories
              .map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Row(
                      children: [
                        const Icon(Icons.place_rounded,
                            size: 18, color: Color(0xFF4F378A)),
                        const SizedBox(width: 10),
                        Text(t.name,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1D1B20),
                            )),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedTerritory = val);
          },
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            activeColor: const Color(0xFF4F378A),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFCBC4D2)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF494551), height: 1.5),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: Color(0xFF4F378A),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Color(0xFF4F378A),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Territory {
  final String id;
  final String name;

  const _Territory(this.id, this.name);
}
