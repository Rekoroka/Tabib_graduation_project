import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendBidScreen extends StatefulWidget {
  final String consultationId;
  const SendBidScreen({super.key, required this.consultationId});

  @override
  State<SendBidScreen> createState() => _SendBidScreenState();
}

class _SendBidScreenState extends State<SendBidScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;
  bool _isExistingOffer = false;

  @override
  void initState() {
    super.initState();
    _checkAndLoadOffer();
  }

  // التحقق من حالة الاستشارة وتحميل العرض القديم
  Future<void> _checkAndLoadOffer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      var consultation = await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .get();

      if (!consultation.exists || consultation.data()?['status'] != 'pending') {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This case is no longer available for bidding."),
            ),
          );
        }
        return;
      }

      var offer = await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .collection('offers')
          .doc(user.uid)
          .get();

      if (offer.exists && mounted) {
        setState(() {
          _isExistingOffer = true;
          _priceController.text = offer.data()?['price'].toString() ?? "";
          _noteController.text = offer.data()?['note'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error loading existing offer: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitBid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _priceController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // 1. جلب بيانات الطبيب الحالية (الاسم، التقييم، وعدد الحالات)
      final doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String doctorName = doctorDoc.data()?['name'] ?? "Doctor";
      final double doctorRating = (doctorDoc.data()?['rating'] ?? 5.0)
          .toDouble();

      // جلب إحصائية الحالات المكتملة من ملف الطبيب
      final int completedCases = doctorDoc.data()?['completedCases'] ?? 0;

      // 2. إضافة أو تحديث العرض مع الإحصائيات الجديدة
      await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .collection('offers')
          .doc(user.uid)
          .set({
            'doctorId': user.uid,
            'doctorName': doctorName,
            'doctorRating': doctorRating,
            'completedCases': completedCases, // الإحصائية التي ستظهر للمريض
            'price': int.parse(_priceController.text),
            'note': _noteController.text,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isExistingOffer
                  ? "Offer updated successfully!"
                  : "Offer sent successfully!",
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error sending bid: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send offer. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isExistingOffer ? "Update Medical Bid" : "Send Medical Bid",
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (_isExistingOffer)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "You are editing your previous offer. Your current stats (Rating & Completed Cases) will be updated in the offer.",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: "Consultation Fee (EGP)",
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: "Add a note for the patient",
                      prefixIcon: Icon(Icons.note_add),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submitBid,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isExistingOffer ? "Update Offer" : "Submit Offer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
