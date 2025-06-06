import 'package:dio/dio.dart';
import 'package:fe/core/api/api_client.dart';
import 'package:fe/features/plant/data/repositories/plant_repository_impl.dart';
import 'package:fe/features/plant/domain/usecases/add_plant.dart';
import 'package:fe/features/plant/domain/usecases/get_my_plants.dart';
import 'package:fe/features/plant/presentation/bloc/plant_bloc.dart';
import 'package:fe/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    // --- Dependency Injection Setup ---
    // This is where we create instances of our services and repositories.
    // In a larger app, you might use a service locator like get_it.
    final dio = Dio();
    final apiClient = ApiClient(dio: dio, sharedPreferences: sharedPreferences);
    final plantRepository = PlantRepositoryImpl(apiClient: apiClient);
    final getMyPlants = GetMyPlants(plantRepository);
    final addPlant = AddPlant(plantRepository);
    // --- End of Dependency Injection ---

    // Using MultiBlocProvider to prepare for more BLoCs in the future
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlantBloc>(
          create: (context) => PlantBloc(
            getMyPlants: getMyPlants,
            addPlant: addPlant,
          ),
        ),
        // You can add other providers for other features here
        // e.g., BlocProvider<AuthBloc>(...),
      ],
      child: MaterialApp(
        title: 'Plant Parent Helper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            // ignore: deprecated_member_use
            background: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
        ),
        // Use the AppRouter for navigation
        onGenerateRoute: AppRouter.generateRoute,
        // Set the initial route, which is the login page
        initialRoute: AppRouter.loginRoute,
      ),
    );
  }
}
