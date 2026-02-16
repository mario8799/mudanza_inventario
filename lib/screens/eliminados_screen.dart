import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class InventariosEliminadosScreen extends StatefulWidget {
  const InventariosEliminadosScreen({Key? key}) : super(key: key);

  @override
  State<InventariosEliminadosScreen> createState() =>
      _InventariosEliminadosScreenState();
}

class _InventariosEliminadosScreenState
    extends State<InventariosEliminadosScreen> {

  List<Map<String, dynamic>> inventarios = [];

  @override
  void initState() {
    super.initState();
    cargarInventariosEliminados();
  }

  Future<void> cargarInventariosEliminados() async {
    final data =
        await DatabaseHelper.instance.getInventariosEliminados();

    setState(() {
      inventarios = data;
    });
  }

  int calcularDiasRestantes(String fechaEliminacion) {
    final fecha = DateTime.parse(fechaEliminacion);
    final limite = fecha.add(const Duration(days: 30));
    return limite.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventarios Eliminados"),
      ),
      body: inventarios.isEmpty
          ? const Center(
              child: Text("No hay inventarios en la papelera"),
            )
          : ListView.builder(
              itemCount: inventarios.length,
              itemBuilder: (context, index) {
                final inv = inventarios[index];
                final fechaEliminacion =
                    DateTime.parse(inv['fecha_eliminacion']);
                final fechaFormateada =
                    DateFormat('dd/MM/yyyy')
                        .format(fechaEliminacion);

                final diasRestantes =
                    calcularDiasRestantes(inv['fecha_eliminacion']);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${inv['numeroInventario']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${inv['nombreCliente']} ${inv['apellidoCliente']}",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Eliminado: $fechaFormateada"),
                            Text(
                              "Se eliminará en: $diasRestantes días",
                              style: TextStyle(
                                color: diasRestantes <= 5
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [

                                // 🔄 RESTAURAR
                                ElevatedButton(
                                  onPressed: () async {
                                    await DatabaseHelper.instance
                                        .restaurarInventario(inv['id']);

                                    await cargarInventariosEliminados();

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Inventario restaurado"),
                                        ),
                                      );
                                    }
                                  },
                                  child:
                                      const Text("Restaurar"),
                                ),

                                // ❌ ELIMINAR DEFINITIVO
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirmar =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                            "Eliminar definitivamente"),
                                        content: const Text(
                                            "Esta acción no se puede deshacer.\n¿Desea continuar?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context,
                                                    false),
                                            child:
                                                const Text(
                                                    "Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context,
                                                    true),
                                            child:
                                                const Text(
                                                    "Eliminar"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar == true) {
                                      await DatabaseHelper.instance
                                          .eliminarInventarioDefinitivo(
                                              inv['id']);

                                      await cargarInventariosEliminados();

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Inventario eliminado definitivamente"),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    "Eliminar",
                                    style: TextStyle(
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
