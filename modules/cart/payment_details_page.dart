// lib/pages/payment_details_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class PaymentDetailsPage extends StatefulWidget {
  final String userName;
  final String categoryName;
  final String packageName;
  final String amount;
  final String currency;
  final String razorpayPaymentId;
  final String razorpayOrderId;

  const PaymentDetailsPage({
    Key? key,
    required this.userName,
    required this.categoryName,
    required this.packageName,
    required this.amount,
    required this.currency,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
  }) : super(key: key);

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _detailAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize the main animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Define the slide and fade animations for the card
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Define staggered animations for each detail row
    _detailAnimations = List.generate(7, (index) {
      final start = 0.5 + (index * 0.07);
      final end = start + 0.3;
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ),
      );
    });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method to build a row with fade and slide animations
  Widget _buildAnimatedDetailRow(String title, String value, int index) {
    return FadeTransition(
      opacity: _detailAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              0.0,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: _buildDetailRow(title, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current date
    final String formattedDate =
        DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: const Color(0xFFBE1744),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bill Header
                      Center(
                        child: Column(
                          children: [
                            // Optionally add a logo
                            // Image.asset('assets/logo.png', height: 80),
                            const SizedBox(height: 10),
                            const Text(
                              'Payment Receipt',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBE1744),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Date: $formattedDate',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 30,
                        thickness: 2,
                        color: Color(0xFFBE1744),
                      ),
                      const SizedBox(height: 10),
                      _buildAnimatedDetailRow('User Name', widget.userName, 0),
                      _buildAnimatedDetailRow(
                          'Category Name', widget.categoryName, 1),
                      _buildAnimatedDetailRow(
                          'Package Name', widget.packageName, 2),
                      _buildAnimatedDetailRow(
                          'Amount', '${widget.currency} ${widget.amount}', 3),
                      _buildAnimatedDetailRow('Currency', widget.currency, 4),
                      _buildAnimatedDetailRow(
                          'Razorpay Payment ID', widget.razorpayPaymentId, 5),
                      _buildAnimatedDetailRow(
                          'Razorpay Order ID', widget.razorpayOrderId, 6),
                      const SizedBox(height: 30),
                      Center(
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: const Interval(0.8, 1.0,
                                  curve: Curves.easeInOut),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate back to the home screen or desired page
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBE1744),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Go to Home',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a row for each detail
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
