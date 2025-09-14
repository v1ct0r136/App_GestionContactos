import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart'; // Ajusta la ruta según tu estructura (e.g., package:formulario_app/main.dart)

void main() {
  testWidgets('Formulario carga correctamente', (WidgetTester tester) async {
    // Construye y renderiza el widget MiAplicacion
    await tester.pumpWidget(const MiAplicacion());

    // Verifica que el título del AppBar esté presente
    expect(find.text('Formulario'), findsOneWidget);

    // Verifica que el campo de texto para ingresar el nombre esté presente
    expect(find.byType(TextFormField), findsOneWidget);

    // Verifica que el botón 'Guardar Nombre' esté presente
    expect(
      find.widgetWithText(ElevatedButton, 'Guardar Nombre'),
      findsOneWidget,
    );

    // Verifica que el botón 'Ver Lista de Nombres' esté presente
    expect(
      find.widgetWithText(ElevatedButton, 'Ver Lista de Nombres'),
      findsOneWidget,
    );
  });

  testWidgets('Navegación a la lista de nombres', (WidgetTester tester) async {
    // Construye y renderiza el widget MiAplicacion
    await tester.pumpWidget(const MiAplicacion());

    // Toca el botón 'Ver Lista de Nombres'
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Ver Lista de Nombres'),
    );
    await tester.pumpAndSettle(); // Espera a que la navegación se complete

    // Verifica que la pantalla de lista se haya cargado
    expect(find.text('Lista de Nombres'), findsOneWidget);
    expect(
      find.text('No hay nombres guardados'),
      findsOneWidget,
    ); // Mensaje inicial
  });
}
