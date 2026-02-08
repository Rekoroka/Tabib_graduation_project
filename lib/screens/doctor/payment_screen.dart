import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentScreen extends StatefulWidget {
  final String consultationId;
  final String doctorId;
  final String doctorName;
  final int amount;

  const PaymentScreen({
    super.key,
    required this.consultationId,
    required this.doctorId,
    required this.doctorName,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // دالة محاكاة الدفع وتحديث البيانات
  Future<void> _handlePaymentSimulation() async {
    // التأكد من ملء البيانات (حتى لو وهمية)
    if (_cardNumberController.text.isEmpty || _expiryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in card details")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // محاكاة تأخير لمدة 3 ثوانٍ لإعطاء إيحاء بالتواصل مع البنك
    await Future.delayed(const Duration(seconds: 3));

    try {
      // تحديث حالة الاستشارة في Firestore لتصبح Active
      await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .update({
            'status': 'active',
            'doctorId': widget.doctorId,
            'doctorName': widget.doctorName,
            'acceptedPrice': widget.amount,
            'paymentStatus': 'paid', // علامة إن الدفع تم
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        // رسالة نجاح مبهجة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // التوجه للشات ومسح شاشة الدفع من الـ Stack
        Navigator.pushReplacementNamed(
          context,
          '/patient-chat',
          arguments: {
            'consultationId': widget.consultationId,
            'doctorName': widget.doctorName,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Secure Payment"),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تفاصيل المبلغ
            _buildSummaryCard(),
            const SizedBox(height: 30),

            const Text(
              "Card Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // حقل رقم الكارت
            _buildCustomField(
              controller: _cardNumberController,
              label: "Card Number",
              hint: "1234 5678 9101 1121",
              icon: Icons.credit_card,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                // تاريخ الانتهاء
                Expanded(
                  child: _buildCustomField(
                    controller: _expiryController,
                    label: "Expiry Date",
                    hint: "MM/YY",
                    icon: Icons.date_range,
                    keyboard: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 15),
                // الـ CVV
                Expanded(
                  child: _buildCustomField(
                    controller: _cvvController,
                    label: "CVV",
                    hint: "123",
                    icon: Icons.lock_outline,
                    keyboard: TextInputType.number,
                    isPassword: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // زر الدفع
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePaymentSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Pay ${widget.amount} EGP Now",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(
                    "Secured by TABIB Payment Gateway",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت ملخص الدفع
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Consultation Fee:"),
              Text(
                "${widget.amount} EGP",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Doctor:"),
              Text(
                "Dr. ${widget.doctorName}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ويدجت الحقول المخصصة
  Widget _buildCustomField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboard,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blue[800]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }
}
