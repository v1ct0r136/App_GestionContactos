import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // Para guardar archivo
import 'package:path_provider/path_provider.dart'; // Para obtener carpeta de documentos
import 'package:share_plus/share_plus.dart'; // Para mostrar el diálogo de "Compartir"

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Contactos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PantallaFormulario(),
      routes: {'/lista': (context) => const PantallaLista()},
    );
  }
}

class PantallaFormulario extends StatefulWidget {
  const PantallaFormulario({super.key});

  @override
  State<PantallaFormulario> createState() => _PantallaFormularioState();
}

class _PantallaFormularioState extends State<PantallaFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController(); // nuevo campo

  Future<void> _guardarContacto(String nombre, String telefono) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contactos = prefs.getStringList('contactos') ?? [];
    contactos.add('$nombre:$telefono'); // guardamos nombre y teléfono juntos
    await prefs.setStringList('contactos', contactos);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contacto guardado')));
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
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Ingresa un teléfono'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarContacto(
                      _nombreController.text,
                      _telefonoController.text,
                    );
                    _nombreController.clear();
                    _telefonoController.clear();
                  }
                },
                child: const Text('Guardar Contacto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/lista');
                },
                child: const Text('Ver Lista de Contactos'),
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
    _telefonoController.dispose();
    super.dispose();
  }
}

class PantallaLista extends StatefulWidget {
  const PantallaLista({super.key});
  @override
  State<PantallaLista> createState() => _PantallaListaState();
}

class _PantallaListaState extends State<PantallaLista> {
  List<String> contactos = [];
  List<String> contactosFiltrados = [];
  final _busquedaController = TextEditingController();

  Future<void> _cargarContactos() async {
    final prefs = await SharedPreferences.getInstance();
    contactos = prefs.getStringList('contactos') ?? [];
    contactosFiltrados = List.from(contactos);
    setState(() {});
  }

  Future<void> _eliminarContacto(int index) async {
    final prefs = await SharedPreferences.getInstance();
    contactos.removeAt(index);
    await prefs.setStringList('contactos', contactos);
    _aplicarFiltro(_busquedaController.text);
  }

  void _aplicarFiltro(String filtro) {
    contactosFiltrados = contactos
        .where((c) => c.toLowerCase().contains(filtro.toLowerCase()))
        .toList();
    setState(() {});
  }

  Future<void> _exportarContactos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contactos = prefs.getStringList('contactos') ?? [];

    if (contactos.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay contactos para exportar')),
        );
      }
      return;
    }

    // Obtener carpeta de documentos
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/contactos.txt');

    // Escribir los contactos en el archivo
    await file.writeAsString(contactos.join('\n'));

    // Mostrar SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo guardado en ${file.path}')),
      );
    }

    // Abrir diálogo de compartir
    await Share.shareXFiles([XFile(file.path)], text: 'Lista de contactos');
  }

  @override
  void initState() {
    super.initState();
    _cargarContactos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Contactos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _busquedaController,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
              ),
              onChanged: _aplicarFiltro,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contactosFiltrados.length,
              itemBuilder: (context, index) {
                final contacto = contactosFiltrados[index];
                final partes = contacto.split(':');
                final nombre = partes[0];
                final telefono = partes.length > 1 ? partes[1] : '';
                return ListTile(
                  title: Text('$nombre: $telefono'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _eliminarContacto(contactos.indexOf(contacto)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportarContactos,
        child: const Icon(Icons.save),
      ),
    );
  }
}
