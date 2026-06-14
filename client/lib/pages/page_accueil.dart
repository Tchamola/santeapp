import 'package:flutter/material.dart';

class PageAccueil extends StatelessWidget {
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital, size: 80, color: Colors.teal),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Système de Suivi Sanitaire',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "Bienvenue dans votre application de gestion épidémiologique et de calcul d'IMC.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
