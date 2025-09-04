import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutBadugaPage extends StatelessWidget {
  // Function to launch a URL
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: ClipOval(
                  child: Image.network(
                    'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg',
                    height: 170,
                    width: 170,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // App Title
              Center(
                child: Text(
                  'Being Baduga',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // App Description
              Text(
                'Being Baduga is a community-driven app that brings together the essence of the Baduga culture and traditions. Our mission is to preserve and promote the rich heritage of the Baduga people, providing a platform where members can connect, share, and celebrate their cultural identity.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                    ),
              ),
              SizedBox(height: 24.0),

              // Our Founder Section
              Text(
                'Our Founder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.0),

              // Founder Information Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading:
                      Icon(Icons.person, color: Theme.of(context).primaryColor),
                  title: Text(
                    'Barath Nanjan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    'Founder of Being Baduga',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                        ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Contact Information
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.0),

              // Phone Contact Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading:
                      Icon(Icons.phone, color: Theme.of(context).primaryColor),
                  title: GestureDetector(
                    onTap: () => _launchURL('tel:+919843864494'),
                    child: Text(
                      '+91 98438 64494',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),

              // Instagram Contact Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.instagram,
                      color: Theme.of(context).primaryColor),
                  title: GestureDetector(
                    onTap: () =>
                        _launchURL('https://www.instagram.com/Barath_nanjan'),
                    child: Text(
                      '@Barath_nanjan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),

              // WhatsApp Contact Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.whatsapp,
                      color: Theme.of(context).primaryColor),
                  title: GestureDetector(
                    onTap: () => _launchURL('https://wa.me/919843864494'),
                    child: Text(
                      '+91 98438 64494',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.0),

              // Appreciation Section
              Text(
                'Acknowledgments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.0),

              // Acknowledgments Section with Bullet Points
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'THANKING ALL MENTIONED PEOPLE FOR BEING A LADDER IN THE JOURNEY OF \n BEING BADUGA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        '• PASU SATHYA (ELITHORAI)\n'
                        '• WEBADUGA\n'
                        '• SANJIV (DENAD)\n'
                        '• PRAVIN (HOSATI - BIKKATI)\n'
                        '• ELITHORAI YOUTH\n'
                        '• PRANESH SHANKAR - NADUHATY\n'
                        '• THARUN - NADUHATY\n'
                        '• GOKUL - NADUHATY\n'
                        '• JITHU KENTHORAI (SAI RESHMA PHOTOGRAPHY)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.0),

              // Final Appreciation Text
              Text(
                'At Being Baduga, we are passionate about preserving our culture and sharing it with the world. We believe in the power of community and the importance of staying connected to our roots. Thank you for being a part of our journey!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
