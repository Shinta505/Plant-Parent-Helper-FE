// lib/routes/app_router.dart
import 'package:fe/features/auth/presentation/pages/login_page.dart';
import 'package:fe/features/auth/presentation/pages/register_page.dart';
import 'package:fe/features/plant/presentation/pages/add_plant_page.dart';
import 'package:fe/features/plant/presentation/pages/my_plants_page.dart';
import 'package:fe/features/plant/presentation/pages/plant_detail_page.dart';
import 'package:fe/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String loginRoute = '/';
  static const String registerRoute = '/register';
  static const String myPlantsRoute = '/my-plants';
  static const String addPlantRoute = '/add-plant';
  static const String plantDetailRoute = '/plant-detail';
  static const String profileRoute = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case myPlantsRoute:
        return MaterialPageRoute(builder: (_) => const MyPlantsPage());
      case addPlantRoute:
        return MaterialPageRoute(builder: (_) => const AddPlantPage());
      case plantDetailRoute:
        return MaterialPageRoute(builder: (_) => const PlantDetailPage());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
