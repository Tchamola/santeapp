import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 10.0.2.2:8000 permet à l'émulateur Android de pointer vers le serveur FastAPI du PC
  static const String baseUrl = "http://10.0.2.2:8000";

  // Fonction pour récupérer les données de santé depuis l'API
  Future<Map<String, dynamic>> fetchStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));
      if (response.statusCode == 200) {
        // On décode le JSON reçu en dictionnaire Dart
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Erreur lors du chargement des stats (Code ${response.statusCode})",
        );
      }
    } catch (e) {
      throw Exception("Impossible de contacter le serveur backend : $e");
    }
  }

  // Fonction pour envoyer un nouveau patient au serveur
  Future<bool> addPatient(
    int age,
    double poids,
    double taille,
    bool survecu,
    String zone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/patients"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age": age,
          "poids": poids,
          "taille": taille,
          "survecu": survecu,
          "zone": zone,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Erreur lors de l'envoi : $e");
    }
  }
}
