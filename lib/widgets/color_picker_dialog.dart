import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({super.key, required this.initialColor});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione uma Cor'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildColorOption(Colors.red),
                _buildColorOption(Colors.pink),
                _buildColorOption(Colors.purple),
                _buildColorOption(Colors.deepPurple),
                _buildColorOption(Colors.indigo),
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.lightBlue),
                _buildColorOption(Colors.cyan),
                _buildColorOption(Colors.teal),
                _buildColorOption(Colors.green),
                _buildColorOption(Colors.lightGreen),
                _buildColorOption(Colors.lime),
                _buildColorOption(Colors.yellow),
                _buildColorOption(Colors.amber),
                _buildColorOption(Colors.orange),
                _buildColorOption(Colors.deepOrange),
                _buildColorOption(Colors.brown),
                _buildColorOption(Colors.grey),
                _buildColorOption(Colors.blueGrey),
                _buildColorOption(Colors.black),
                _buildColorOption(Colors.white),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black26, width: 2),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Cor Atual',
                  style: TextStyle(
                    color: _currentColor.computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null); // Cancela
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal.shade700,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop(_currentColor); // Retorna a cor selecionada
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Selecionar'),
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentColor = color;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentColor == color
                ? Colors.teal.shade700
                : Colors.transparent,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
