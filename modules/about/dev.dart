import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutYelbeePage extends StatelessWidget {
  // Function to launch a URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
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
              Center(
                child: ClipOval(
                  child: Image.network(
                    'https://res.cloudinary.com/dordpmvpm/image/upload/v1725376741/awlcz8yu1pgrxzu6irme.jpg',
                    height: 170,
                    width: 170,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'YELBEE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Set to black as per request
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'YELBEE is a premier software development company that specializes in providing innovative and effective digital solutions to help businesses thrive in the digital age.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16.0),
              Text(
                'Our Services:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '• Search Engine Optimization (SEO)\n'
                '• Mobile App Development\n'
                '• Website Design and Development\n'
                '• Custom Software Solutions\n'
                '• E-commerce Platforms\n'
                '• Cloud Services\n'
                '• Data Analytics and AI Solutions\n'
                '• IT Consulting',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16.0),
              // Adjust the height to avoid overflow
              Container(
                height: 350, // Reduced height to avoid overflow
                child: GridView.builder(
                  shrinkWrap:
                      true, // Allows GridView to be used inside a Column
                  physics:
                      NeverScrollableScrollPhysics(), // Prevent inner scrolling
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio:
                        0.6, // Adjust child aspect ratio as needed
                  ),
                  itemCount: 2, // Number of developer tiles
                  itemBuilder: (context, index) {
                    // Developer information data
                    final developerInfo = [
                      {
                        'imageUrl':
                            'https://res.cloudinary.com/dordpmvpm/image/upload/v1725134787/a0yrhyfd9y0tavihf1af.jpg',
                        'name': 'Mr. Bevin Samraj',
                        'role': 'Full Stack Developer',
                        'phone': '+91 72000 53453',
                        'whatsappUrl': 'https://wa.me/917200053453',
                        'instagramUrl': 'https://www.instagram.com/bev.y__',
                      },
                      {
                        'imageUrl':
                            'https://res.cloudinary.com/dordpmvpm/image/upload/v1725375417/fdwkcqlvzappfpi9dnjt.jpg',
                        'name': 'Mr. beingbaduga',
                        'role': 'Database Administrator',
                        'phone': '+91 91594 63092',
                        'whatsappUrl': 'https://wa.me/919159463092',
                        'instagramUrl':
                            'https://www.instagram.com/beingbaduga__05',
                      },
                    ];

                    return _buildDeveloperTile(
                      context,
                      developerInfo[index]['imageUrl']!,
                      developerInfo[index]['name']!,
                      developerInfo[index]['role']!,
                      developerInfo[index]['phone']!,
                      developerInfo[index]['whatsappUrl']!,
                      developerInfo[index]['instagramUrl']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperTile(BuildContext context, String imageUrl, String name,
      String role, String phone, String whatsappUrl, String instagramUrl) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // Changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Adjusts to the minimum size of content
        children: [
          ClipOval(
            child: Image.network(
              imageUrl,
              height: 150, // Larger size for visibility
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            role,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.phone,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                onPressed: () => _launchURL('tel:$phone'),
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                onPressed: () => _launchURL(whatsappUrl),
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.instagram,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                onPressed: () => _launchURL(instagramUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
