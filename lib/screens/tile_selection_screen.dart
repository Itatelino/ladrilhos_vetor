// ignore: unused_import
//import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ladrilhos_app/models/tile_model.dart';
import 'package:ladrilhos_app/screens/cart_screen.dart';
import 'package:ladrilhos_app/screens/tile_customization_screen.dart';

class TileSelectionScreen extends StatelessWidget {
  const TileSelectionScreen({super.key});

  // Adiciona o método para carregar e modificar o SVG
  Future<String> _loadAndModifySvgAsset(
    BuildContext context,
    String assetPath,
    List<Color> currentColors,
    List<String> initialHexColorsInSvg,
  ) async {
    // Carrega o SVG como string
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetPath);

    // Substitui as cores iniciais pelas cores atuais
    for (int i = 0;
        i < initialHexColorsInSvg.length && i < currentColors.length;
        i++) {
      final initialHex = initialHexColorsInSvg[i].toLowerCase();
      final currentHex =
          // ignore: deprecated_member_use
          '#${currentColors[i].value.toRadixString(16).padLeft(8, '0').substring(2)}';
      svgString = svgString.replaceAll(initialHex, currentHex);
    }
    return svgString;
  }

  @override
  Widget build(BuildContext context) {
    // Determine o número de colunas com base na largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 180).floor(); // Ex: 180px por item
    final aspectRatio = screenWidth < 600
        ? 0.7
        : 0.8; // Ajusta o aspect ratio para telas menores

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione seu Ladrilho'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount > 0
              ? crossAxisCount
              : 1, // Garante pelo menos 1 coluna
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: aspectRatio,
        ),
        itemCount: availableTiles.length,
        itemBuilder: (context, index) {
          final tile = availableTiles[index];
          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip
                .antiAlias, // Para garantir que a imagem não vaze dos cantos arredondados
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TileCustomizationScreen(tile: tile),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FutureBuilder<String>(
                        future: _loadAndModifySvgAsset(
                          context,
                          tile.svgAssetPath,
                          tile.currentColors,
                          tile.initialHexColorsInSvg,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return SvgPicture.string(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            );
                          } else if (snapshot.hasError) {
                            return const Center(child: Icon(Icons.error));
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        tile.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
