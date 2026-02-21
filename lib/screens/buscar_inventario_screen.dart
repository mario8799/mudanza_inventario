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
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> inventariosFiltrados = [];

  @override
  void initState() {
    super.initState();
    cargarInventarios();
  }

  Future<void> cargarInventarios() async {
    final data = await DatabaseHelper.instance.getInventariosActivos();
    setState(() {
      inventarios = data;
      inventariosFiltrados = data;
    });
  }

  void buscarInventario() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      inventariosFiltrados = inventarios.where((inv) {
        final numero =
            inv['numeroInventario'].toString().toLowerCase();
        final nombre =
            inv['nombreCliente'].toString().toLowerCase();
        final apellido =
            inv['apellidoCliente'].toString().toLowerCase();

        return numero.contains(query) ||
            nombre.contains(query) ||
            apellido.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: "Buscar por número o cliente...",
    prefixIcon: const Icon(Icons.search),
    suffixIcon: IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        _searchController.clear();
        setState(() {
          inventariosFiltrados = inventarios;
        });
      },
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  onChanged: (value) {
    final query = value.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        inventariosFiltrados = inventarios;
      } else {
        inventariosFiltrados = inventarios.where((inv) {
          final numero =
              inv['numeroInventario'].toString().toLowerCase();
          final nombre =
              inv['nombreCliente'].toString().toLowerCase();
          final apellido =
              inv['apellidoCliente'].toString().toLowerCase();

          return numero.contains(query) ||
              nombre.contains(query) ||
              apellido.contains(query);
        }).toList();
      }
    });
  },
),
          ),
          Expanded(
            child: inventarios.isEmpty
                ? const Center(
                    child:
                        Text("DataBase Empty"))
                : inventariosFiltrados.isEmpty
                    ? const Center(
                        child: Text("No matches"))
                    : ListView.builder(
                        itemCount:
                            inventariosFiltrados.length,
                        itemBuilder: (context, index) {
                          final inv =
                              inventariosFiltrados[index];
                          final fechaCreacion =
                              DateTime.parse(
                                  inv['fechaCreacion']);
                          final fechaFormateada =
                              DateFormat('dd/MM/yyyy')
                                  .format(fechaCreacion);

                          return Card(
                            margin:
                                const EdgeInsets.all(10),
                            child: ExpansionTile(
                              title: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "#${inv['numeroInventario']}",
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${inv['nombreCliente']} ${inv['apellidoCliente']}",
                                    style:
                                        const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.all(
                                          12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                          "Origin: ${inv['direccionOrigen']}"),
                                      Text(
                                          "Destination: ${inv['direccionDestino']}"),
                                      Text(
                                          "Created: $fechaFormateada"),
                                      const SizedBox(
                                          height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed:
                                                () async {
                                              final opcion =
                                                  await showDialog<
                                                      String>(
                                                context:
                                                    context,
                                                builder: (_) =>
                                                    AlertDialog(
                                                  title:
                                                      const Text(
                                                          "Choose PDF"),
                                                  content:
                                                      const Text(
                                                          "What would you like to print?"),
                                                  actions: [
  TextButton(
    onPressed: () =>
        Navigator.pop(context, "inventario"),
    child: const Text("Inventory"),
  ),
  TextButton(
    onPressed: () =>
        Navigator.pop(context, "high_value"),
    child: const Text("High Value"),
  ),
  TextButton(
    onPressed: () =>
        Navigator.pop(context, "pg"),
    child: const Text("Pro Gear"),
  ),
],
                                                ),
                                              );

                                              if (opcion ==
                                                  null)
                                                return;

                                              if (opcion == "inventario") {
  await generarPdfCompleto(inv['id']);
} else if (opcion == "high_value") {
  await generarPdfHighValue(inv['id']);
} else if (opcion == "pg") {
  await generarPdfProGear(inv['id']);
}

                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content:
                                                        Text(
                                                            "PDF DONE"),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text(
                                                "Print"),
                                          ),
                                          ElevatedButton(
                                            style:
                                                ElevatedButton
                                                    .styleFrom(
                                              backgroundColor:
                                                  Colors.red,
                                            ),
                                            onPressed:
                                                () async {
                                              final confirmar =
                                                  await showDialog<
                                                      bool>(
                                                context:
                                                    context,
                                                builder: (_) =>
                                                    AlertDialog(
                                                  title:
                                                      const Text(
                                                          "Delete Inventory"),
                                                  content:
                                                      const Text(
                                                          "This inventory will be eliminated within 30 days.\nContinue?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context,
                                                              false),
                                                      child:
                                                          const Text(
                                                              "Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context,
                                                              true),
                                                      child:
                                                          const Text(
                                                              "Delete"),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmar ==
                                                  true) {
                                                await DatabaseHelper
                                                    .instance
                                                    .marcarInventarioEliminado(
                                                        inv[
                                                            'id']);

                                                await cargarInventarios();

                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content:
                                                          Text(
                                                              "Inventario marcado para eliminación"),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child:
                                                const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors
                                                      .white),
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
          ),
        ],
      ),
    );
  }
}