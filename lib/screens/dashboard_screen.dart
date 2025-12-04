import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import 'employee_page.dart';
import 'login_page.dart';
import 'product_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (AuthService.avatarPath != null &&
                        AuthService.avatarPath!.isNotEmpty)
                    ? FileImage(File(AuthService.avatarPath!))
                    : null,
                child:
                    (AuthService.avatarPath == null ||
                        AuthService.avatarPath!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              onPressed: () {
                final Map<String, dynamic> profile = AuthService.getProfile();
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Profile'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('First name: ${profile['firstName'] ?? ''}'),
                          const SizedBox(height: 6),
                          Text('Last name: ${profile['lastName'] ?? ''}'),
                          const SizedBox(height: 6),
                          Text('Date of birth: ${profile['dob'] ?? ''}'),
                          const SizedBox(height: 6),
                          Text('Email: ${profile['email'] ?? ''}'),
                          const SizedBox(height: 6),
                          Text('Mobile: ${profile['mobile'] ?? ''}'),
                        ],
                      ),
                      actions: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          label: const Text('Edit Profile'),
                          onPressed: () {
                            Navigator.of(context).pop();

                            final TextEditingController firstCtrl =
                                TextEditingController(
                                  text: profile['firstName'] ?? '',
                                );
                            final TextEditingController lastCtrl =
                                TextEditingController(
                                  text: profile['lastName'] ?? '',
                                );
                            final TextEditingController dobCtrl =
                                TextEditingController(
                                  text: profile['dob'] ?? '',
                                );
                            final TextEditingController emailCtrl =
                                TextEditingController(
                                  text: profile['email'] ?? '',
                                );
                            final TextEditingController mobileCtrl =
                                TextEditingController(
                                  text: profile['mobile'] ?? '',
                                );

                            String? avatarLocal = profile['avatarPath'];
                            final ImagePicker picker = ImagePicker();

                            showDialog<void>(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    Future<void> pickImage() async {
                                      final XFile? file = await picker
                                          .pickImage(
                                            source: ImageSource.gallery,
                                          );
                                      if (file != null) {
                                        setState(() {
                                          avatarLocal = file.path;
                                        });
                                      }
                                    }

                                    return AlertDialog(
                                      title: const Text('Edit Profile'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: pickImage,
                                              child: CircleAvatar(
                                                radius: 36,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                backgroundImage:
                                                    (avatarLocal != null &&
                                                        (avatarLocal
                                                                ?.isNotEmpty ??
                                                            false))
                                                    ? FileImage(
                                                        File(avatarLocal!),
                                                      )
                                                    : null,
                                                child:
                                                    (avatarLocal == null ||
                                                        (avatarLocal?.isEmpty ??
                                                            true))
                                                    ? const Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.grey,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: firstCtrl,
                                              decoration: const InputDecoration(
                                                labelText: 'First name',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: lastCtrl,
                                              decoration: const InputDecoration(
                                                labelText: 'Last name',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: dobCtrl,
                                              readOnly: true,
                                              onTap: () async {
                                                final DateTime? picked =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.tryParse(
                                                            dobCtrl.text,
                                                          ) ??
                                                          DateTime(1990, 1, 1),
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime.now(),
                                                    );
                                                if (picked != null) {
                                                  setState(() {
                                                    dobCtrl.text =
                                                        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                                  });
                                                }
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Date of birth',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: mobileCtrl,
                                              keyboardType: TextInputType.phone,
                                              decoration: const InputDecoration(
                                                labelText: 'Mobile',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: emailCtrl,
                                              decoration: const InputDecoration(
                                                labelText: 'Email',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            AuthService.updateProfile(
                                              newFirstName: firstCtrl.text
                                                  .trim(),
                                              newLastName: lastCtrl.text.trim(),
                                              newDob: dobCtrl.text.trim(),
                                              newEmail: emailCtrl.text.trim(),
                                              newMobile: mobileCtrl.text.trim(),
                                              newAvatarPath: avatarLocal,
                                            );
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Profile updated',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            AuthService.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
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
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'Dashboard Content Goes Here',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 60.0,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: SizedBox.shrink(),
            ),
          ),
          _buildDrawerItem(
            text: 'DashBoard',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            text: 'Products',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductPage())),
          ),
          _buildDrawerItem(
            text: 'Employees',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EmployeePage())),
          ),
          _buildDrawerItem(text: 'Members', onTap: () {}),
          _buildDrawerItem(text: 'Analysis', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required String text, required VoidCallback onTap}) {
    return ListTile(
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
