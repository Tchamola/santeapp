import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageSaisie extends StatefulWidget {
  const PageSaisie({super.key});

  @override
  State<PageSaisie> createState() => _PageSaisieState();
}

class _PageSaisieState extends State<PageSaisie> {
  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer le texte saisi dans les champs
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();

  // Variables pour nos composants interactifs (sélections)
  String _zoneSelectionnee = 'Zone Urbaine';
  bool _aSurvequ = true;
  bool _enCoursDenvoi = false;

  // Fonction pour envoyer les données du patient à notre API FastAPI
  Future<void> _enregistrerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCoursDenvoi = true;
    });

    // L'adresse de notre serveur FastAPI (accessible depuis l'émulateur Android)
    const String apiUrl = "http://10.0.2.2:8000/patients";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age": int.parse(_ageController.text),
          "poids": double.parse(_poidsController.text),
          "taille": double.parse(_tailleController.text), // En mètres, ex: 1.75
          "survecu": _aSurvequ,
          "zone": _zoneSelectionnee,
        }),
      );

      setState(() {
        _enCoursDenvoi = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Succès ! On affiche un petit message de confirmation en bas
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient ajouté avec succès !'),
            backgroundColor: Colors.teal,
          ),
        );

        // On vide le formulaire pour la saisie suivante
        _ageController.clear();
        _poidsController.clear();
        _tailleController.clear();
        setState(() {
          _aSurvequ = true;
          _zoneSelectionnee = 'Zone Urbaine';
        });
      } else {
        throw Exception('Erreur serveur (Code: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _enCoursDenvoi = false;
      });

      // En cas d'erreur (serveur éteint, etc.), on prévient l'utilisateur
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec de l'enregistrement : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // On libère la mémoire des contrôleurs quand la page n'est pas affichée
    _ageController.dispose();
    _poidsController.dispose();
    _tailleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisie Patient'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // --- CHAMP ÂGE ---
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Âge',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake, color: Colors.teal),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer l'âge";
                    }
                    if (int.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- CHAMP POIDS ---
                TextFormField(
                  controller: _poidsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Poids (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight, color: Colors.teal),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le poids';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre correct';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- CHAMP TAILLE ---
                TextFormField(
                  controller: _tailleController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Taille (m)',
                    helperText: 'Exemple : 1.75 ou 1.62',

                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.height, color: Colors.teal),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer la taille';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre correct';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // --- MENU DÉROULANT : ZONE GÉOGRAPHIQUE ---
                DropdownButtonFormField<String>(
                  initialValue: _zoneSelectionnee,
                  decoration: const InputDecoration(
                    labelText: 'Zone géographique',
                    border: OutlineInputBorder(),

                    prefixIcon: Icon(Icons.map, color: Colors.teal),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Zone Urbaine',
                      child: Text('Zone Urbaine'),
                    ),
                    DropdownMenuItem(
                      value: 'Zone Rurale',
                      child: Text('Zone Rurale'),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _zoneSelectionnee = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 25),

                // --- SWITCH / INTERRUPTEUR : SURVIE ---
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.health_and_safety, color: Colors.teal),
                            SizedBox(width: 12),
                            Text('A survécu ?', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Switch(
                          value: _aSurvequ,

                          activeThumbColor: Colors.teal,
                          onChanged: (value) {
                            setState(() {
                              _aSurvequ = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                // --- BOUTON D'ENREGISTREMENT ---
                ElevatedButton(
                  onPressed: _enCoursDenvoi ? null : _enregistrerPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _enCoursDenvoi
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
