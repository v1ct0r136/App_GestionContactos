import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Formulario',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PantallaFormulario(),
      routes: {'/lista': (context) => const PantallaLista()},
    );
  }
}

class PantallaFormulario extends StatefulWidget {
  const PantallaFormulario({super.key});

  @override
  State<PantallaFormulario> createState() => _PantallaFormularioState(); // Estado privado
}

class _PantallaFormularioState extends State<PantallaFormulario> {
  // Privado
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  Future<void> _guardarNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> nombres = prefs.getStringList('nombres') ?? [];
    nombres.add(nombre);
    await prefs.setStringList('nombres', nombres);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nombre guardado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Ingresa tu nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarNombre(_nombreController.text);
                    _nombreController.clear();
                  }
                },
                child: const Text('Guardar Nombre'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/lista');
                },
                child: const Text('Ver Lista de Nombres'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }
}

class PantallaLista extends StatelessWidget {
  const PantallaLista({super.key});

  Future<List<String>> _obtenerNombres() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('nombres') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Nombres')),
      body: FutureBuilder<List<String>>(
        future: _obtenerNombres(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay nombres guardados'));
          }
          final nombres = snapshot.data!;
          return ListView.builder(
            itemCount: nombres.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(nombres[index]));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
