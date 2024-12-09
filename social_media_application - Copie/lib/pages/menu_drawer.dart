import 'package:flutter/material.dart';
import 'package:social_media_application/pages/ad_creation.dart'; // Import the AdCreation page

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        // Change the background color of the drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black
                , // Change header background color
              ),
              accountName: Text(
                "Pixsellz",
                style: TextStyle(color: Colors.white), // Change account name color
              ),
              accountEmail: Text(
                "@pixsellz",
                style: TextStyle(color: Colors.white), // Change account email color
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/images/swiftie.jpg"),
              ),
            ),
            // Wrap ListTiles with InkWell for tap effects
            _createDrawerItem(
              context,
              icon: Icons.person,
              text: "Profile",
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile page or perform an action
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.ads_click,
              text: "Create Ad",
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdCreation(), // Navigate to AdCreation page
                  ),
                );
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.group,
              text: "Groups",
              onTap: () {
                Navigator.pop(context);
                // Navigate to groups page or perform an action
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.event,
              text: "Events",
              onTap: () {
                Navigator.pop(context);
                // Navigate to events page or perform an action
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.shop,
              text: "E-Shop",
              onTap: () {
                Navigator.pop(context);
                // Navigate to e-shop page or perform an action
              },
            ),
            Divider(color: Colors.grey),
            _createDrawerItem(
              context,
              icon: Icons.bookmark,
              text: "Bookmarks",
              onTap: () {
                Navigator.pop(context);
                // Navigate to bookmarks page or perform an action
              },
            ),
            _createDrawerItem(
              context,
              text: "Settings and privacy",
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page or perform an action
              },
            ),
            _createDrawerItem(
              context,
              text: "Help Center",
              onTap: () {
                Navigator.pop(context);
                // Navigate to help center page or perform an action
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a ListTile with tap effect
  Widget _createDrawerItem(BuildContext context, {IconData? icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.black, // Background color for dark mode
        child: ListTile(
          leading: icon != null ? Icon(icon, color: Colors.white70) : null, // Light gray icon color
          title: Text(
            text,
            style: const TextStyle(color: Colors.white), // White text color
          ),
          tileColor: Colors.black, // Ensure tile background is black
          hoverColor: Colors.white12, // Subtle hover effect in dark mode
        ),
      ),
    );
  }
}
