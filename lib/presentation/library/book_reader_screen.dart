import 'package:flutter/material.dart';
import 'package:islamic_app/domain/entities/book.dart';

class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  double _fontSize = 18.0;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;

  void _toggleTheme() {
    setState(() {
      if (_backgroundColor == Colors.white) {
        _backgroundColor = const Color(0xFF1E1E1E);
        _textColor = Colors.white;
      } else {
        _backgroundColor = Colors.white;
        _textColor = Colors.black;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Font Size',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _fontSize,
                        min: 12,
                        max: 32,
                        onChanged: (value) {
                          setState(() => _fontSize = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: _backgroundColor != Colors.white,
                            onChanged: (_) {
                              Navigator.pop(context);
                              _toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          """
In the name of Allah, the Most Gracious, the Most Merciful.

Chapter 1: The Beginning

This is a mock text representing the content of the book "${widget.book.title}". In a real application, this content would be fetched from a remote server or a local database.

Islam teaches us peace, compassion, and the importance of seeking knowledge. The first word revealed in the Quran was "Iqra" (Read), emphasizing the significance of education and understanding.

...

(Mock content continues...)

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

...

End of Chapter 1.
          """,
          style: TextStyle(fontSize: _fontSize, color: _textColor, height: 1.6),
        ),
      ),
    );
  }
}
