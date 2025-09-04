import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/utils/CPSessionManager.dart';
import 'package:beingbaduga/utils/PreferenceUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPage extends StatefulWidget {
  final String amount;
  final String packageName;
  final String categoryName;
  final String userId;
  final String categoryId;
  final String packageId;
  final String duration;

  RazorPage({
    required this.amount,
    required this.packageName,
    required this.categoryName,
    required this.userId,
    required this.categoryId,
    required this.packageId,
    required this.duration,
  });

  @override
  _RazorPageState createState() => _RazorPageState();
}

class _RazorPageState extends State<RazorPage> {
  late Razorpay _razorpay;
  User? user;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    var jsonEncode = PreferenceUtils.getString(CPSessionManager.USER);
    user = User.fromJson(jsonDecode(jsonEncode));
  }

  @override
  void dispose() {
    _razorpay.clear(); // Release resources
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_live_ILgsfZCZoFIKMb', // Replace with your live key
      'amount': (double.parse(widget.amount) * 100).toInt(),
      'name': widget.packageName,
      'description': widget.categoryName,
      'prefill': {
        'contact': user?.phone ?? '', // Replace with actual user contact
        'email': user?.email ?? '', // Replace with actual user email
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
      _showMessage('Error in opening Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showMessage("Payment Successful: ${response.paymentId}");
    _updatePaymentDetails('on', response.paymentId ?? '');
    // Redirect to login after success
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showMessage("Payment Failed: ${response.code} - ${response.message}");
    _updatePaymentDetails('off', '');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showMessage("External Wallet Selected: ${response.walletName}");
  }

  void _updatePaymentDetails(String status, String paymentId) async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://beingbaduga.com/being_baduga/update_master_payment.php'),
        body: {
          'paymentId': paymentId,
          'status': status,
          'userId': widget.userId,
          'categoryId': widget.categoryId,
          'packageId': widget.packageId,
          'amount_paid': widget.amount,
          'paidDate': DateTime.now().toString(),
          'nextDueDate': DateTime.now()
              .add(Duration(days: int.parse(widget.duration)))
              .toString(),
          'duration': widget.duration,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          _showMessage('Payment details updated successfully');
          _navigateToLogin();
        } else {
          _showMessage(jsonResponse['message'] ?? 'Unknown error');
        }
      } else {
        _showMessage('Failed to update payment details on the server.');
      }
    } catch (e) {
      _showMessage('An error occurred while updating payment details: $e');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razorpay Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 48.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            'Proceed to Payment',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
