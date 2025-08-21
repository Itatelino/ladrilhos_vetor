import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ladrilhos_app/models/tile_model.dart';
import 'package:ladrilhos_app/widgets/color_picker_dialog.dart';

class TileCustomizationScreen extends StatefulWidget {
  final Tile tile;

  const TileCustomizationScreen({super.key, required this.tile});

  @override
  State<TileCustomizationScreen> createState() =>
      _TileCustomizationScreenState();
}

class _TileCustomizationScreenState extends State<TileCustomizationScreen> {
  late Tile _currentTile;
  final TextEditingController _widthController = TextEditingController(
    text: '20',
  );
  final TextEditingController _heightController = TextEditingController(
    text: '20',
  );
  double _quantityPerSqMeter = 0.0;
  int _orderQuantity = 1;

  @override
  void initState() {
    super.initState();
    _currentTile = widget.tile
        .copyWith(); // Criar uma cópia para evitar modificar o original
    _calculateQuantityPerSqMeter();
    _widthController.addListener(_calculateQuantityPerSqMeter);
    _heightController.addListener(_calculateQuantityPerSqMeter);
  }

  @override
  void dispose() {
    _widthController.removeListener(_calculateQuantityPerSqMeter);
    _heightController.removeListener(_calculateQuantityPerSqMeter);
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // Função para calcular ladrilhos por m²
  void _calculateQuantityPerSqMeter() {
    final double? width = double.tryParse(_widthController.text);
    final double? height = double.tryParse(_heightController.text);

    if (width != null && height != null && width > 0 && height > 0) {
      final double areaCm2 = width * height;
      final double areaM2 = areaCm2 / 10000; // Converter cm² para m²
      setState(() {
        _quantityPerSqMeter = 1.0 / areaM2;
      });
    } else {
      setState(() {
        _quantityPerSqMeter = 0.0;
      });
    }
  }

  // Função para abrir o seletor de cores
  Future<void> _pickColor(int partIndex) async {
    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          initialColor: _currentTile.currentColors[partIndex],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        _currentTile.currentColors[partIndex] = pickedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizar ${_currentTile.name}'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FutureBuilder<String>(
                    future: _loadAndModifySvgAsset(
                      _currentTile.svgAssetPath,
                      _currentTile.currentColors,
                      _currentTile.initialHexColorsInSvg,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return SvgPicture.string(
                          snapshot.data!,
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.width * 0.6,
                          fit: BoxFit.contain,
                        );
                      } else if (snapshot.hasError) {
                        return const Center(child: Icon(Icons.error));
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Cores do Ladrilho:',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: List.generate(_currentTile.colorablePartNames.length, (
                index,
              ) {
                return GestureDetector(
                  onTap: () => _pickColor(index),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _currentTile.currentColors[index],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentTile.colorablePartNames[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _currentTile.currentColors[index]
                                      .computeLuminance() >
                                  0.5
                              ? Colors.black87
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            Text(
              'Dimensões do Ladrilho (cm):',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Largura (cm)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixText: 'cm',
                      prefixIcon: const Icon(Icons.line_weight),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Altura (cm)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixText: 'cm',
                      prefixIcon: const Icon(Icons.height),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Text(
                'Ladrilhos por m²: ${_quantityPerSqMeter.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Quantidade para Pedido:',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuantityButton(Icons.remove, () {
                  if (_orderQuantity > 1) {
                    setState(() {
                      _orderQuantity--;
                    });
                  }
                }),
                SizedBox(
                  width: 100,
                  child: Text(
                    _orderQuantity.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.teal.shade800,
                        ),
                  ),
                ),
                _buildQuantityButton(Icons.add, () {
                  setState(() {
                    _orderQuantity++;
                  });
                }),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                final double? width = double.tryParse(_widthController.text);
                final double? height = double.tryParse(_heightController.text);

                if (width == null ||
                    height == null ||
                    width <= 0 ||
                    height <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, insira dimensões válidas para o ladrilho.',
                      ),
                    ),
                  );
                  return;
                }

                final orderItem = OrderItem(
                  tile: _currentTile
                      .copyWith(), // Adiciona uma cópia profunda para o carrinho
                  widthCm: width,
                  heightCm: height,
                  quantityPerSqMeter: _quantityPerSqMeter,
                  orderQuantity: _orderQuantity,
                );
                cart.add(orderItem);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${orderItem.tile.name} adicionado ao carrinho!',
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );
                Navigator.pop(context); // Volta para a tela de seleção
              },
              icon: const Icon(Icons.add_shopping_cart, size: 28),
              label: const Text('Adicionar ao Carrinho'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
        backgroundColor: Colors.teal.shade100,
        foregroundColor: Colors.teal.shade800,
        elevation: 3,
      ),
      child: Icon(icon, size: 28),
    );
  }

  // Método para carregar e modificar o SVG substituindo as cores
  Future<String> _loadAndModifySvgAsset(
    String assetPath,
    List<Color> currentColors,
    List<String> initialHexColorsInSvg,
  ) async {
    // Carrega o SVG como string
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetPath);

    // Substitui cada cor inicial pela cor atual selecionada
    for (int i = 0;
        i < initialHexColorsInSvg.length && i < currentColors.length;
        i++) {
      final String oldColor = initialHexColorsInSvg[i].toLowerCase();
      final String newColor =
          // ignore: deprecated_member_use
          '#${currentColors[i].value.toRadixString(16).padLeft(8, '0').substring(2)}';
      svgString = svgString.replaceAll(oldColor, newColor);
    }
    return svgString;
  }
}
