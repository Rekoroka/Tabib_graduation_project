import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/tabib_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.5)),

          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // App logo and title
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      "assets/images/tabib.jpg", // مسار الصورة الجديدة
                      fit: BoxFit.cover, // تغطية كاملة للدائرة
                      errorBuilder: (context, error, stackTrace) {
                        // إذا لم توجد الصورة، عرض بديل
                        return const Icon(
                          Icons.medical_services,
                          size: 60,
                          color: Colors.green,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "TABIB",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                const Text(
                  "Detect plant diseases instantly with AI technology",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
