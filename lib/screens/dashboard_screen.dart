import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. The App Bar (Header)
      appBar: AppBar(
        // Set the background color to match the light purple/lilac shade
        backgroundColor: Colors.grey[200], 
        
        // Title Text
        title: const Text(
          'Wel come Back',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true, // Center the title

        // Icon for the user profile on the right (Actions)
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
        
        // Icon for the Drawer on the left (automatically handles the hamburger icon)
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),

      // 2. The Drawer (Slide-out menu)
      drawer: const AppDrawer(),

      // 3. The Body (where dashboard content will go)
      body: const Center(
        child: Text(
          'Dashboard Content Goes Here',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// 4. Drawer Widget (Menu content)
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // The menu content is built in a Drawer widget
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // You need a DrawerHeader to push the menu items down
          const SizedBox(
            height: 60.0, // Match the height of the AppBar
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: SizedBox.shrink(), // Empty header
            ),
          ),

          // Menu Items
          _buildDrawerItem(
            text: 'DashBoard',
            onTap: () => Navigator.pop(context), // Close drawer
          ),
          _buildDrawerItem(text: 'Products', onTap: () {}),
          _buildDrawerItem(text: 'Employees', onTap: () {}),
          _buildDrawerItem(text: 'Members', onTap: () {}),
          _buildDrawerItem(text: 'Analysis', onTap: () {}),
        ],
      ),
    );
  }

  // Helper function to build consistent menu items
  Widget _buildDrawerItem({required String text, required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}