import 'package:flutter/material.dart';

class BookCardInfo extends StatelessWidget {
  final String itmName;
  final String itmDescrip;
  final String itmAutor;
  final String itmGenero;
  final String itmImg;
  final void Function()? onPress;

  BookCardInfo(
      {super.key,
      required this.itmName,
      required this.itmDescrip,
      required this.itmAutor,
      required this.itmGenero,
      required this.itmImg,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              // Colors.purple,
              //Colors.pink,
              Colors.blueGrey,
              Colors.grey
            ]),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 3, color: Colors.green)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                itmImg,
                width: 100,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              itmName.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // Corta con "..."
            ),
            Text(
              itmDescrip,
              style: const TextStyle(fontSize: 10, color: Colors.white),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.green.shade900,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    itmAutor,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 1,
                  ),
                ),
                ElevatedButton.icon(
                    onPressed: onPress,
                    icon: const Icon(
                      Icons.remove_red_eye,
                    ),
                    label: const Text('Leer')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
