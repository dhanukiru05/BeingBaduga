// lib/pages/purchase_confirmation_page.dart

import 'dart:developer';
import 'dart:convert';
import 'package:beingbaduga/modules/cart/payment_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:beingbaduga/CardBankResponseResponse.dart';
import 'package:beingbaduga/UPIBankResponse.dart';
import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/modules/cart/package_model.dart';

class PurchaseConfirmationPage extends StatefulWidget {
  final User user;
  final List<Package> selectedPackages;

  const PurchaseConfirmationPage({
    Key? key,
    required this.user,
    required this.selectedPackages,
  }) : super(key: key);

  @override
  _PurchaseConfirmationPageState createState() =>
      _PurchaseConfirmationPageState();
}

class _PurchaseConfirmationPageState extends State<PurchaseConfirmationPage> {
  late Razorpay _razorpay;

  // API endpoint URLs
  final String createOrderUrl =
      'https://beingbaduga.com/being_baduga/create_order.php';
  final String paymentResponseUrl =
      'https://beingbaduga.com/being_baduga/payment_response.php';

  Package? _currentPackage;
  String _currentOrderId = "";

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Function to initiate Razorpay payment
  void _startPayment(double totalAmount, String orderId, Package package) {
    // Use different Razorpay key for Matrimony category
    String razorpayKey;
    if (package.categoryId == 2) {
      // Matrimony
      razorpayKey =
          'rzp_live_NgebciNQdUpaxh'; // <<< Use your Matrimony Razorpay Key
    } else {
      razorpayKey = 'rzp_live_Od356qyDi3heDI'; // Default key
    }

    var options = {
      'key': razorpayKey,
      'amount': (totalAmount * 100).toInt(),
      'currency': 'INR',
      'name': 'Being Baduga',
      'description': 'Purchase Confirmation ${package.packageName}',
      'theme': {'color': '#BE1744'},
      'order_id': orderId,
      'prefill': {
        'contact': widget.user.phone,
        'email': widget.user.email,
      },
      'notes': {
        'user_id': widget.user.id.toString(),
        'category_id': package.categoryId.toString(),
        'package_id': package.packageId.toString(),
        'mobile_type': 'Android',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error in payment: ${e.toString()}')),
      );
    }
  }

  // Event handler for payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log("Payment Successful Payment ID: ${response.paymentId}");
    _bankResponseData(response.paymentId.toString());
  }

  // Event handler for payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  // Event handler for external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  // Function to create order
  Future<void> _orderCreate(Package package) async {
    // Validate all required fields before making the request
    if (widget.user.id <= 0 ||
        package.categoryId <= 0 ||
        package.packageId <= 0 ||
        package.price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Missing required fields. Please try again.')),
      );
      return;
    }

    try {
      var response = await http.post(Uri.parse(createOrderUrl), body: {
        'user_id': widget.user.id.toString(),
        'category_id': package.categoryId.toString(),
        'package_id': package.packageId.toString(),
        'amount': package.price.toString(),
        'order_status': "no",
        'currency': "INR",
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log("Order Data : ${responseData.toString()}");
        if (responseData['status'] == 'success') {
          String orderId = responseData['raz_order_data']["id"];
          var serverOrderId = responseData['order_id'];
          print(
              "Razor Pay Order Id : $orderId :  serverOrderId : $serverOrderId");
          setState(() {
            _currentOrderId = orderId;
            _currentPackage = package;
          });
          _startPayment(package.price, orderId, package);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Function to handle purchase confirmation after successful payment
  Future<void> _bankResponseData(String paymentId) async {
    try {
      var response = await http.post(Uri.parse(paymentResponseUrl), body: {
        'razorpay_order_id': _currentOrderId,
        'razorpay_payment_id': paymentId,
      });
      print(
          "Order Id: $_currentOrderId : payment_id : $paymentId , amount : ${_currentPackage?.price.toString()} ");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // Navigate to PaymentDetailsPage with payment details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetailsPage(
                userName: widget.user.name,
                categoryName: _currentPackage?.categoryName ?? "",
                packageName: _currentPackage?.packageName ?? "",
                amount: _currentPackage?.price.toString() ?? "",
                currency: "INR",
                razorpayPaymentId: paymentId,
                razorpayOrderId: _currentOrderId,
              ),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase Confirmed!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Confirmation'),
        centerTitle: true,
        backgroundColor: const Color(0xFFBE1744),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Confirmation Message Container
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to confirm the purchase?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Review the details of the selected packages before proceeding.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4A4A),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // List of Selected Packages
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedPackages.length,
                itemBuilder: (context, index) {
                  final package = widget.selectedPackages[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: package.imageUrl,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 120,
                                width: 120,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 120,
                                width: 120,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  package.packageName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  package.description,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Price: ₹${package.price}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFBE1744),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Confirmation Purchase Button
            ElevatedButton(
              onPressed: () {
                if (widget.selectedPackages.isNotEmpty) {
                  final package = widget.selectedPackages.first;
                  _currentPackage = package;
                  _orderCreate(package);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No packages selected.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBE1744),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Confirm Purchase',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
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
