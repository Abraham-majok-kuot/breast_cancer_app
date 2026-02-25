import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// Back button
            
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),
                ),

                const SizedBox(height: 40),

                /// Heart icon
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.pink,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 24),

                /// Title
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Join us for better health insights",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 32),

                /// Card container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// Full Name
                        const Text("Full Name"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Enter your name",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Enter your name"
                                  : null,
                        ),

                        const SizedBox(height: 20),

                        /// Email
                        const Text("Email"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) =>
                              value == null || !value.contains('@')
                                  ? "Enter a valid email"
                                  : null,
                        ),

                        const SizedBox(height: 20),

                        /// Gender Dropdown
                        const Text("Gender"),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.people_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          hint: const Text("Select gender"),
                          items: const [
                            DropdownMenuItem(
                              value: "Male",
                              child: Text("Male"),
                            ),
                            DropdownMenuItem(
                              value: "Female",
                              child: Text("Female"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? "Select gender" : null,
                        ),

                        const SizedBox(height: 20),

                        /// Password
                        const Text("Password"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null,
                        ),

                        const SizedBox(height: 28),

                        /// Create Account Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A9C93),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Account created successfully"),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Create Account",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Sign In link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Already have an account? Sign in",
                              style: TextStyle(
                                color: Color(0xFF6A9C93),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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