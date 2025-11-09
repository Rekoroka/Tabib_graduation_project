import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;

  // دالة للتحقق من الحقول غير الفارغة
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "⚠️ Please enter your $fieldName";
    }
    return null;
  }

  Future<void> _signIn() async {
    // التحقق من صحة النموذج والحقول غير الفارغة
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Login successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // الانتقال إلى شاشة الـ Home/Upload بعد تسجيل الدخول الناجح
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ $errorMessage"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ An unexpected error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // دالة للانتقال إلى شاشة التسجيل
  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // الجزء العلوي (الصورة)
          Container(
            height: size.height * 0.3,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/tabib_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // الجزء الأبيض
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // التحقق من أن الحقل غير فارغ
                        String? emptyValidation = _validateNotEmpty(
                          value,
                          "email",
                        );
                        if (emptyValidation != null) return emptyValidation;

                        // التحقق من صحة formato البريد الإلكتروني
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                          return "⚠️ Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
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
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        // التحقق من أن الحقل غير فارغ
                        String? emptyValidation = _validateNotEmpty(
                          value,
                          "password",
                        );
                        if (emptyValidation != null) return emptyValidation;

                        // التحقق من طول كلمة المرور
                        if (value!.length < 6) {
                          return "⚠️ Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Sign in button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _loading ? null : _signIn,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign up redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don’t have an account? "),
                        GestureDetector(
                          onTap: _navigateToSignUp,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
