// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';
  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String getUser = '/users/me';

  // Plant Endpoints
  static const String plants = '/plants'; // GET all plants for the user
  static const String addPlant = '/plants'; // POST to add a new plant
  static const String updatePlant =
      '/plants'; // PUT to update a plant (e.g., /plants/{id})
  static const String deletePlant =
      '/plants'; // DELETE a plant (e.g., /plants/{id})
}
