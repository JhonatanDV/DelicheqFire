import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalificarRestaurante extends StatefulWidget {
  @override
  _CalificarRestauranteState createState() => _CalificarRestauranteState();
}

class _CalificarRestauranteState extends State<CalificarRestaurante> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  double _calificacion = 0;
  String? _selectedRestaurantId;
  String? _selectedRestaurantName;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _calificarRestaurante() async {
    if (_formKey.currentState!.validate() && _calificacion > 0 && _selectedRestaurantId != null) {
      await FirebaseFirestore.instance.collection('users_rating').add({
        'restaurant_id': _selectedRestaurantId,
        'restaurant_name': _selectedRestaurantName,
        'calificacion': _calificacion,
        'comentario': _comentarioController.text,
        'fecha': Timestamp.now(),
      });

      _comentarioController.clear();
      setState(() {
        _calificacion = 0; // Reiniciar calificación
        _selectedRestaurantId = null; // Reiniciar selección de restaurante
        _selectedRestaurantName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calificación enviada con éxito!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona un restaurante, una calificación y escribe un comentario.')),
      );
    }
  }

  Future<List<Map<String, String>>> _fetchRestaurants() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('restaurant_register').get();
    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'nombre': doc['nombre'] as String,
      } as Map<String, String>;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users_rating').get();
    return querySnapshot.docs.map((doc) {
      return {
        'restaurant_name': doc['restaurant_name'],
        'calificacion': doc['calificacion'],
        'comentario': doc['comentario'],
        'fecha': (doc['fecha'] as Timestamp).toDate(),
      } as Map<String, dynamic>;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificar Restaurante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Selecciona un Restaurante:',
                style: TextStyle(fontSize: 20),
              ),
              FutureBuilder<List<Map<String, String>>>(
                future: _fetchRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  List<Map<String, String>> restaurants = snapshot.data ?? [];

                  return DropdownButtonFormField<String>(
                    hint: Text('Elige un restaurante'),
                    value: _selectedRestaurantId,
                    items: restaurants.map((restaurant) {
                      return DropdownMenuItem<String>(
                        value: restaurant['id'],
                        child: Text(restaurant['nombre']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRestaurantId = value;
                        _selectedRestaurantName = restaurants.firstWhere((element) => element['id'] == value)['nombre'];
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona un restaurante.';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Califica el Restaurante:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                            index < _calificacion ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _calificacion = index + 1.0; // Asignar la calificación
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _comentarioController,
                decoration: InputDecoration(labelText: 'Comentario'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un comentario.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calificarRestaurante,
                child: Text('Enviar Calificación'),
              ),
              SizedBox(height: 20),
              Text(
                'Reseñas:',
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchReviews(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    List<Map<String, dynamic>> reviews = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        var review = reviews[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(review['restaurant_name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Calificación: ${review['calificacion']}'),
                                Text('Comentario: ${review['comentario']}'),
                                Text('Fecha: ${review['fecha'].toLocal().toString().split(' ')[0]}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}