import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaRestaurantes extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchRestaurantsWithRatings() async {
    // Obtener todos los restaurantes
    QuerySnapshot restaurantsSnapshot = await FirebaseFirestore.instance.collection('restaurant_register').get();
    List<Map<String, dynamic>> restaurantsWithRatings = [];

    for (var restaurantDoc in restaurantsSnapshot.docs) {
      // Obtener las calificaciones de cada restaurante
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('users_rating')
          .where('restaurant_id', isEqualTo: restaurantDoc.id)
          .get();

      // Calcular la calificación promedio
      double averageRating = 0.0;
      if (ratingsSnapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        for (var ratingDoc in ratingsSnapshot.docs) {
          totalRating += ratingDoc['calificacion'];
        }
        averageRating = totalRating / ratingsSnapshot.docs.length;
      }

      // Agregar el restaurante y su calificación promedio a la lista
      restaurantsWithRatings.add({
        'id': restaurantDoc.id,
        'nombre': restaurantDoc['nombre'],
        'calificacion_promedio': averageRating,
      });
    }

    return restaurantsWithRatings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Restaurantes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRestaurantsWithRatings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Map<String, dynamic>> restaurants = snapshot.data ?? [];

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              var restaurant = restaurants[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(restaurant['nombre']),
                  subtitle: Text('Calificación Promedio: ${restaurant['calificacion_promedio'].toStringAsFixed(1)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}