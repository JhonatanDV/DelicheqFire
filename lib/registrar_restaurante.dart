import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarRestaurante extends StatefulWidget {
  @override
  _RegistrarRestauranteState createState() => _RegistrarRestauranteState();
}

class _RegistrarRestauranteState extends State<RegistrarRestaurante> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _tipoCocinaController = TextEditingController();

  Future<void> _registrarRestaurante() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('restaurant_register').add({
        'nombre': _nombreController.text,
        'direccion': _direccionController.text,
        'tipo_cocina': _tipoCocinaController.text,
      });

      _nombreController.clear();
      _direccionController.clear();
      _tipoCocinaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restaurante registrado con éxito!')),
      );

      setState(() {}); // Actualiza la lista después de registrar
    }
  }

  Future<void> _eliminarRestaurante(String id) async {
    await FirebaseFirestore.instance.collection('restaurant_register').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restaurante eliminado con éxito!')),
    );
    setState(() {}); // Actualiza la lista después de eliminar
  }

  Future<void> _editarRestaurante(String id) async {
    await FirebaseFirestore.instance.collection('restaurant_register').doc(id).update({
      'nombre': _nombreController.text,
      'direccion': _direccionController.text,
      'tipo_cocina': _tipoCocinaController.text,
    });

    _nombreController.clear();
    _direccionController.clear();
    _tipoCocinaController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restaurante editado con éxito!')),
    );
    setState(() {}); // Actualiza la lista después de editar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Restaurante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre del Restaurante'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _direccionController,
                    decoration: InputDecoration(labelText: 'Dirección'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la dirección.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _tipoCocinaController,
                    decoration: InputDecoration(labelText: 'Tipo de Cocina'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el tipo de cocina.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registrarRestaurante,
                    child: Text('Registrar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('restaurant_register').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final restaurants = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return ListTile(
                        title: Text(restaurant['nombre']),
                        subtitle: Text('${restaurant['direccion']} - ${restaurant['tipo_cocina']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                                                _nombreController.text = restaurant['nombre'];
                                _direccionController.text = restaurant['direccion'];
                                _tipoCocinaController.text = restaurant['tipo_cocina'];

                                // Almacenar el ID del restaurante que se está editando
                                String restaurantId = restaurant.id;

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Editar Restaurante'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: _nombreController,
                                            decoration: InputDecoration(labelText: 'Nombre del Restaurante'),
                                          ),
                                          TextFormField(
                                            controller: _direccionController,
                                            decoration: InputDecoration(labelText: 'Dirección'),
                                          ),
                                          TextFormField(
                                            controller: _tipoCocinaController,
                                            decoration: InputDecoration(labelText: 'Tipo de Cocina'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            _editarRestaurante(restaurantId);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Guardar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancelar'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _eliminarRestaurante(restaurant.id);
                              },
                            ),
                          ],
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
    );
  }
}
                                