import 'package:beingbaduga/modules/about/dev.dart';
import 'package:flutter/material.dart';
import 'about_baduga.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Update the length to 2 since one tab is removed
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'About Us',
            style: TextStyle(
              color: Colors.white, // Set title text color to white
              fontSize: Theme.of(context).appBarTheme.titleTextStyle?.fontSize,
              fontWeight:
                  Theme.of(context).appBarTheme.titleTextStyle?.fontWeight,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white, // Set selected tab text color to white
            unselectedLabelColor: Colors.white.withOpacity(
                0.6), // Set unselected tab text color to a lighter shade of white
            tabs: [
              Tab(text: 'Being Baduga'),
              Tab(text: 'YelBee'),
            ],
          ),
          backgroundColor: Theme.of(context)
              .appBarTheme
              .backgroundColor, // Use theme AppBar color
        ),
        body: TabBarView(
          children: [
            AboutBadugaPage(), // Reference to the AboutBadugaPage class
            AboutYelbeePage(), // Reference to the AboutDeveloperPage class
          ],
        ),
      ),
    );
  }
}
