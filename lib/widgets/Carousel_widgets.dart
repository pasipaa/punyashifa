import 'dart:async';
import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {

  final List<String> images;
  final double height;

  const CarouselWidget({
    super.key,
    required this.images,
    required this.height,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {

  late PageController controller;

  int currentIndex = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    controller = PageController(
      viewportFraction: 0.9,
    );

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {

        if (controller.hasClients) {

          currentIndex++;

          if (currentIndex >= widget.images.length) {
            currentIndex = 0;
          }

          controller.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );

          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        SizedBox(
          height: widget.height,

          child: PageView.builder(
            controller: controller,
            itemCount: widget.images.length,

            itemBuilder: (context, index) {

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Image.asset(
                    widget.images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: List.generate(
            widget.images.length,

            (index) {

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),

                width: currentIndex == index ? 10 : 7,
                height: currentIndex == index ? 10 : 7,

                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? const Color(0xff1F5B4D)
                      : Colors.grey,

                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        )
      ],
    );
  }
}