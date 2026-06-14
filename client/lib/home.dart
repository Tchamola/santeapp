import 'package:flutter/material.dart';
import 'package:client/pages/page_resultats.dart';
import 'package:client/pages/page_saisie.dart';
import 'package:client/pages/page_accueil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Contrôle la page actuellement affichée (0 = Accueil, 1 = Saisie, 2 = Résultats)
  int _currentIndex = 0;

  // Liste de nos 3 pages distinctes
  final List<Widget> _pages = [PageAccueil(), PageSaisie(), PageResultats()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      // ✨ La barre de boutons en bas de l'écran
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Change de page au clic
          });
        },
        selectedItemColor: Colors.teal,

        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Saisie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Résultats',
          ),
        ],
      ),
    );
  }
}
