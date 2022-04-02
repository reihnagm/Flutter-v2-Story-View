import 'package:flutter/material.dart';

class SwipeUp extends StatefulWidget {
  final Widget body;
  final Widget child;
  final VoidCallback? onSwipe;
  final double sensitivity;
  final bool showArrow;
  final Color color;
  final bool animate;
  final bool expand;
  const SwipeUp(
    {Key? key,  
      required this.body,
      required this.child,
      this.onSwipe,
      this.sensitivity = 0.5,
      this.showArrow = true,
      this.color = Colors.black54,
      this.animate = true,
      this.expand = true
    })
    : assert(sensitivity > 0 && sensitivity <= 1), super(key: key);
  @override
  _SwipeUpState createState() => _SwipeUpState();
}

class _SwipeUpState extends State<SwipeUp> with SingleTickerProviderStateMixin {
  late double _initialOffset;
  late double _swipeOffset;

  late AnimationController _animationController;
  late CurvedAnimation _animation;

  @override
  void initState() {
    _initialOffset = 0.0;
    _swipeOffset = 0.0;
    if (widget.animate) initialAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initialAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500), 
      vsync: this
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.25, curve: Curves.decelerate)
    );
    _animationController.repeat(reverse: true);
    _animation.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (details) {
        setState(() {
          _initialOffset = details.globalPosition.dy;
        });
      },
      onVerticalDragUpdate: (details) {
        if (details.globalPosition.dy - _initialOffset < 0.0) {
          setState(() {
            _swipeOffset = -(details.globalPosition.dy - _initialOffset) *
                widget.sensitivity;
          });
        }
      },
      onVerticalDragEnd: (details) {
        if (_swipeOffset > MediaQuery.of(context).size.height / 8) {
          widget.onSwipe?.call();
        }
        setState(() {
          _swipeOffset = 0.0;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.body,
          Positioned(
            bottom: widget.animate 
            ? (_swipeOffset / 2) + (MediaQuery.of(context).size.height / 40 * (1-_animation.value))
            : _swipeOffset / 2,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.showArrow
                ? Icon(
                    Icons.keyboard_arrow_up, 
                    color: widget.color
                  )
                : Container(),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 200,
                    bottom: MediaQuery.of(context).size.height / 40.0
                  ),
                  child: widget.expand
                  ? Transform.scale(
                    scale: 1 + (_swipeOffset * 2 / (MediaQuery.of(context).size.height)),
                    child: widget.child)
                  : widget.child
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}