import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab22/bilesen/tile.dart';
import '../saglayıcılar/controller.dart';

class Grid extends StatefulWidget {
  final int letterCount;

  const Grid({Key? key, required this.letterCount}) : super(key: key);

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (context, controller, child) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(36, 20, 36, 20),
          itemCount: widget.letterCount *
              widget.letterCount, // Grid boyutunu dinamik hale getiriyoruz.
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            crossAxisCount: widget.letterCount, // Dinamik sütun sayısı.
          ),
          itemBuilder: (context, index) {
            String letter = controller.getLetterAt(index);
            return Tile(
                index: index,
                letter: letter); // Harfi Controller'dan alarak Tile'a aktar
          },
        );
      },
    );
  }
}
