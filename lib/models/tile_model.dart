// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';

class Tile {
  final String id;
  final String name;
  final String svgAssetPath; // Caminho para o arquivo SVG na pasta assets
  List<Color> currentColors; // Cores atuais das partes do ladrilho
  final List<String>
      colorablePartNames; // Nomes das partes coloríveis (ex: 'Fundo', 'Desenho')
  final List<String>
      initialHexColorsInSvg; // Cores hex originais no SVG para substituição

  Tile({
    required this.id,
    required this.name,
    required this.svgAssetPath,
    required this.colorablePartNames,
    required this.initialHexColorsInSvg,
    List<Color>? initialColors,
  }) : currentColors = initialColors ??
            List.generate(colorablePartNames.length, (index) => Colors.grey);

  // Criar uma cópia do ladrilho com novas cores
  Tile copyWith({List<Color>? currentColors}) {
    return Tile(
      id: id,
      name: name,
      svgAssetPath: svgAssetPath,
      colorablePartNames: colorablePartNames,
      initialHexColorsInSvg: initialHexColorsInSvg,
      initialColors: currentColors ?? this.currentColors,
    );
  }
}

class OrderItem {
  final Tile tile;
  final double widthCm;
  final double heightCm;
  final double quantityPerSqMeter; // Quantidade de ladrilhos por m²
  int orderQuantity; // Quantidade total a ser pedida

  OrderItem({
    required this.tile,
    required this.widthCm,
    required this.heightCm,
    required this.quantityPerSqMeter,
    this.orderQuantity = 1, // Default para 1
  });

  // Calcula a área do ladrilho em metros quadrados
  double get areaSqMeter => (widthCm / 100) * (heightCm / 100);

  // Calcula o custo (exemplo, você pode adicionar um preço base ao Tile)
  double get estimatedCost =>
      orderQuantity * 10.0; // Exemplo: R$10 por ladrilho
}

// Data simulada (Substitua por seus próprios SVGs e configurações de cores)
final List<Tile> availableTiles = [
  Tile(
    id: 'tile_001',
    name: 'Ladrilho Geométrico',
    svgAssetPath: 'assets/svg/tile_geometric.svg', // Agora carrega de assets
    colorablePartNames: [
      'Fundo',
      'Círculo Central',
      'Quadrado Superior Esquerdo',
      'Quadrado Inferior Direito',
    ],
    initialColors: [
      Colors.blueGrey[100]!,
      Colors.green,
      Colors.amber,
      Colors.blue,
    ],
    initialHexColorsInSvg: ['#E0E0E0', '#4CAF50', '#FFC107', '#2196F3'],
  ),
  Tile(
    id: 'tile_002',
    name: 'Ladrilho Floral',
    svgAssetPath: 'assets/svg/tile_floral.svg', // Agora carrega de assets
    colorablePartNames: ['Fundo', 'Pétala', 'Centro da Flor'],
    initialColors: [Colors.purple[50]!, Colors.deepPurple, Colors.yellow],
    initialHexColorsInSvg: ['#F0F0F0', '#9C27B0', '#FFEB3B'],
  ),
  Tile(
    id: 'tile_003',
    name: 'Ladrilho com Padrão',
    svgAssetPath: 'assets/svg/tile_pattern.svg', // Agora carrega de assets
    colorablePartNames: [
      'Fundo',
      'Linha Diagonal 1',
      'Linha Diagonal 2',
      'Pontos dos Cantos',
    ],
    initialColors: [
      Colors.green[50]!,
      Colors.deepOrange,
      Colors.teal,
      Colors.amber,
    ],
    initialHexColorsInSvg: ['#E8F5E9', '#FF5722', '#009688', '#FFC107'],
  ),
];

// Global list para o carrinho
List<OrderItem> cart = [];

// Helper para carregar e modificar SVG de asset
// ignore: unused_element
Future<String> _loadAndModifySvgAsset(
  String assetPath,
  List<Color> colors,
  List<String> initialHexColorsInSvg,
) async {
  String svgString = await DefaultAssetBundle.of(
    // ignore: prefer_const_constructors
    Color.fromARGB(255, 255, 255, 255) as BuildContext,
  ).loadString(assetPath);
  String modifiedSvgData = svgString;

  for (int i = 0; i < colors.length; i++) {
    if (i < initialHexColorsInSvg.length) {
      String originalHex = initialHexColorsInSvg[i];
      String newHex =
          // ignore: deprecated_member_use
          '#${colors[i].value.toRadixString(16).substring(2).toUpperCase()}';
      // Substitui tanto fill quanto stroke
      modifiedSvgData = modifiedSvgData.replaceAll(
        'fill="$originalHex"',
        'fill="$newHex"',
      );
      modifiedSvgData = modifiedSvgData.replaceAll(
        'stroke="$originalHex"',
        'stroke="$newHex"',
      );
    }
  }
  return modifiedSvgData;
}
