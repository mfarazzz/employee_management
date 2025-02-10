import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSlidable extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final double slideAmount;

  const CustomSlidable({
    Key? key,
    required this.child,
    required this.onDelete,
    this.slideAmount = 0.2,
  }) : super(key: key);

  @override
  _CustomSlidableState createState() => _CustomSlidableState();
}

class _CustomSlidableState extends State<CustomSlidable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-widget.slideAmount, 0), // Slide left by 20% of screen width
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleSlide() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background delete button
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                color: Colors.red,
                icon: SvgPicture.asset(
                  'assets/icons/delete.svg',
                  height: 24,
                  width: 24,
                  color: Colors.red,
                ),
                onPressed: widget.onDelete,
              ),
            ),
          ),
        ),

        // The Swipable Item
        SlideTransition(
          position: _offsetAnimation,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.primaryDelta! < -5) {
                _toggleSlide();
              } else if (details.primaryDelta! > 5) {
                _controller.reverse();
              }
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
