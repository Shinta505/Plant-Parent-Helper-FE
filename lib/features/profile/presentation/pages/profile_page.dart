// lib/features/profile/presentation/pages/profile_page.dart
import 'package:fe/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text("Shinta Nurrohmah"),
            accountEmail: Text("shinta.nurrohmah.if@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("S", style: TextStyle(fontSize: 40.0)),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.loginRoute, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
