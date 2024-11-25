import 'package:flutter/material.dart';
import 'lista_restaurantes.dart'; // Asegúrate de crear este archivo
import 'registrar_restaurante.dart'; // Asegúrate de crear este archivo
import 'calificar_restaurante.dart'; // Asegúrate de crear este archivo
import 'map_page.dart'; // Importa la página del mapa

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaRestaurantes()),
                );
              },
              child: Text('Ver Restaurantes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrarRestaurante()),
                );
              },
              child: Text('Registrar Restaurante'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalificarRestaurante()),
                );
              },
              child: Text('Calificar Restaurante'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()), // Navegar a la página del mapa
                );
              },
              child: Text('Ver Mapa'),
            ),
          ],
        ),
      ),
    );
  }
}