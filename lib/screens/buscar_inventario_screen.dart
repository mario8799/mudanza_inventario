import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/pdf_generator_service.dart';
import 'package:intl/intl.dart';

class BuscarInventarioScreen extends StatefulWidget {
  const BuscarInventarioScreen({super.key});

  @override
  State<BuscarInventarioScreen> createState() =>
      _BuscarInventarioScreenState();
}

class _BuscarInventarioScreenState extends State<BuscarInventarioScreen> {
  List<Map<String, dynamic>> inventarios = [];

  @override
  void initState() {
    super.initState();
    cargarInventarios();
  }

  Future<void> cargarInventarios() async {
    final data = await DatabaseHelper.instance.getInventariosActivos();
    setState(() {
      inventarios = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar Inventario"),
      ),
      body: inventarios.isEmpty
          ? const Center(child: Text("No hay inventarios registrados"))
          : ListView.builder(
              itemCount: inventarios.length,
              itemBuilder: (context, index) {
                final inv = inventarios[index];
                final fechaCreacion = DateTime.parse(inv['fechaCreacion']);
                final fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaCreacion);
                return Card(
  margin: const EdgeInsets.all(10),
  child: ExpansionTile(
    title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "#${inv['numeroInventario']}",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      "${inv['nombreCliente']} ${inv['apellidoCliente']}",
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    ),
  ],
),

    children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Origen: ${inv['direccionOrigen']}"),
            Text("Destino: ${inv['direccionDestino']}"),
            Text("Creado: $fechaFormateada"),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final opcion = await showDialog<String>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Elegir PDF"),
                        content:
                            const Text("¿Qué deseas imprimir?"),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, "inventario"),
                            child:
                                const Text("Inventario completo"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, "high_value"),
                            child:
                                const Text("Lista High Value"),
                          ),
                        ],
                      ),
                    );

                    if (opcion == null) return;

                    if (opcion == "inventario") {
                      await generarPdfCompleto(inv['id']);
                    } else {
                      await generarPdfHighValue(inv['id']);
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                            content: Text(
                                "PDF generado correctamente")),
                      );
                    }
                  },
                  child: const Text("Imprimir"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title:
                            const Text("Eliminar Inventario"),
                        content: const Text(
                            "Este inventario será eliminado en 30 días.\n¿Desea continuar?"),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child:
                                const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child:
                                const Text("Eliminar"),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await DatabaseHelper.instance
                          .marcarInventarioEliminado(inv['id']);

                      await cargarInventarios();

                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Inventario marcado para eliminación")),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Eliminar",
                    style:
                        TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
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
