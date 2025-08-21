import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ladrilhos_app/models/tile_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<String> _loadAndModifySvgAsset(
    String assetPath,
    List<Color> colors,
    List<String> initialHexColorsInSvg,
  ) async {
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetPath);
    for (int i = 0;
        i < colors.length && i < initialHexColorsInSvg.length;
        i++) {
      final hexColor =
          // ignore: deprecated_member_use
          '#${colors[i].value.toRadixString(16).substring(2).toUpperCase()}';
      svgString = svgString.replaceAll(initialHexColorsInSvg[i], hexColor);
    }
    return svgString;
  }

  void _removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removido do carrinho.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _sendOrderViaWhatsApp() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seu carrinho está vazio!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String message =
        'Olá! Gostaria de fazer o seguinte pedido de ladrilhos:\n\n';
    double totalEstimatedCost = 0.0;

    for (int i = 0; i < cart.length; i++) {
      final item = cart[i];
      message += '--- Item ${i + 1} ---\n';
      message += 'Ladrilho: ${item.tile.name}\n';
      message +=
          'Dimensões: ${item.widthCm.toStringAsFixed(1)}cm x ${item.heightCm.toStringAsFixed(1)}cm\n';
      message +=
          'Quantidade por m²: ${item.quantityPerSqMeter.toStringAsFixed(2)}\n';
      message += 'Quantidade Total: ${item.orderQuantity} unidades\n';
      message += 'Cores Personalizadas: ';
      for (int j = 0; j < item.tile.colorablePartNames.length; j++) {
        message +=
            // ignore: deprecated_member_use
            '${item.tile.colorablePartNames[j]}: #${item.tile.currentColors[j].value.toRadixString(16).substring(2).toUpperCase()} ';
      }
      message += '\n';
      totalEstimatedCost += item.estimatedCost;
      message +=
          'Custo Estimado deste item: R\$${item.estimatedCost.toStringAsFixed(2)}\n\n';
    }

    message +=
        'Custo Total Estimado do Pedido: R\$${totalEstimatedCost.toStringAsFixed(2)}\n';
    message +=
        'Aguardamos seu contato para finalizar os detalhes e o pagamento.';

    // Número de telefone para WhatsApp (com código do país, sem '+' ou '00')
    const String whatsappNumber = '5547992680847'; // Substitua pelo seu número

    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o WhatsApp. Verifique se o aplicativo está instalado.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Carrinho'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Seu carrinho está vazio!',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String>(
                                future: _loadAndModifySvgAsset(
                                  item.tile.svgAssetPath,
                                  item.tile.currentColors,
                                  item.tile.initialHexColorsInSvg,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return SvgPicture.string(
                                      snapshot.data!,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.contain,
                                    );
                                  } else if (snapshot.hasError) {
                                    return const SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: Center(child: Icon(Icons.error)),
                                    );
                                  }
                                  return const SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.tile.name,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Dimensões: ${item.widthCm.toStringAsFixed(1)}cm x ${item.heightCm.toStringAsFixed(1)}cm',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Qtd. por m²: ${item.quantityPerSqMeter.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Quantidade Total: ${item.orderQuantity}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      // ignore: deprecated_member_use
                                      'Cores: ${item.tile.currentColors.map((c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}').join(', ')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        'Custo Estimado: R\$${item.estimatedCost.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                    onPressed: _sendOrderViaWhatsApp,
                    //icon: const Icon(Icons.whatsapp, size: 30),
                    label: const Text('Enviar Pedido via WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
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
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Botão de largura total
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
