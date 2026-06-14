import 'package:client/api_service.dart';
import 'package:flutter/material.dart';

class PageResultats extends StatefulWidget {
  const PageResultats({super.key});

  @override
  State<PageResultats> createState() => _PageResultatsState();
}

class _PageResultatsState extends State<PageResultats> {
  final ApiService _apiService = ApiService();

  // On stockele Future dans une variable pour pouvoir le rafraichir
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    // Premier chargement au lancement de la page
    _statsFuture = _apiService.fetchStats();
  }

  // Fonction magique pour relancer la requête vers l'API Python
  void _rafraichirDonnees() {
    setState(() {
      _statsFuture = _apiService.fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques & Résultats'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        // On ajoute le bouton de rafraichissement en haut à droite
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Actualiser les données",
            onPressed: _rafraichirDonnees,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture, // On utilise notre variable ici
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            final data = snapshot.data!;
            final globales = data['Statistiques_globales'] ?? {};

            if (globales.isEmpty) {
              return const Center(child: Text("Aucun patient enregistré."));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Statistiques Globales',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.people, color: Colors.teal),
                      title: const Text('Nombre total de cas'),
                      trailing: Text(
                        '${globales['nombre_total_cas']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.cake, color: Colors.orange),
                      title: const Text('Âge moyen'),
                      trailing: Text(
                        '${globales['age_moyen_ans']} ans',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.monitor_weight,
                        color: Colors.blue,
                      ),
                      title: const Text('IMC Moyen'),
                      trailing: Text(
                        '`${globales['imc_moyen_global']} kg/m²',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: const Text('Taux de létalité'),
                      trailing: Text(
                        '${globales['taux_letalite_pourcentage']}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Aucune donnée disponible.'));
        },
      ),
    );
  }
}
