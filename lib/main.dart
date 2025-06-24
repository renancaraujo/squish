import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Offset startOffset = Offset.zero;
  double squishAndgle = 0.0;
  double squishFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(assetKey: 'shaders/squish.frag', (context, shader, _) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                startOffset = details.globalPosition;
                squishAndgle = 0.0;
                squishFactor = 1.0;
              });
            },
            onPanCancel: () {
              setState(() {
                startOffset = Offset.zero;
                squishAndgle = 0.0;
                squishFactor = 1.0;
              });
            },
            onPanEnd: (details) {
              setState(() {
                startOffset = Offset.zero;
                squishAndgle = 0.0;
                squishFactor = 1.0;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                final delta = details.globalPosition - startOffset;
                final deltaOffset = delta.direction;
                squishAndgle = ((deltaOffset * 180 / pi) + 90) % 360;
                final distance = delta.distance;
                squishFactor = (distance / 50.0).clamp(1.0, 4.0);
              });
            },
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 100),
              tween: Tween<double>(begin: squishFactor, end: squishFactor),
              curve: Curves.bounceOut,
              builder: (context, squishFactor, child) {
                return AnimatedSampler(
                  (ui.Image image, Size size, ui.Canvas canvas) {
                    shader
                      ..setFloatUniforms((u) {
                        u
                          ..setSize(size)
                          ..setFloat(squishAndgle)
                          ..setFloat(squishFactor);
                      })
                      ..setImageSampler(0, image);
                
                    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
                  },
                  child: Padding(
                                        padding: const EdgeInsets.all(40),

                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      );
    });
  }
}
