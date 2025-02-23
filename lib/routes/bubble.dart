library bubble;

import 'package:flutter/material.dart';

enum BubbleNip { no, leftTop, leftBottom, rightTop, rightBottom, leftCenter }

class BubbleEdges {
  const BubbleEdges.fromLTRB(this.left, this.top, this.right, this.bottom);

  const BubbleEdges.all(double value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const BubbleEdges.only({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
  });

  const BubbleEdges.symmetric({
    double vertical = 0.0,
    double horizontal = 0.0,
  })  : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  final double left;
  final double top;
  final double right;
  final double bottom;

  static get zero => const BubbleEdges.all(0);

  EdgeInsets get edgeInsets => EdgeInsets.fromLTRB(left, top, right, bottom);

  @override
  String toString() => 'BubbleEdges($left, $top, $right, $bottom)';
}

class BubbleStyle {
  const BubbleStyle({
    this.radius = const Radius.circular(6.0),
    this.nip = BubbleNip.no,
    this.nipWidth = 8.0,
    this.nipHeight = 10.0,
    this.nipOffset = 0.0,
    this.nipRadius = 1.0,
    this.stick = false,
    this.color = Colors.white,
    this.elevation = 1.0,
    this.shadowColor = Colors.black,
    this.padding = const BubbleEdges.all(8.0),
    this.margin = const BubbleEdges.all(0.0),
    this.alignment = Alignment.center,
  });

  final Radius radius;
  final BubbleNip nip;
  final double nipHeight;
  final double nipWidth;
  final double nipOffset;
  final double nipRadius;
  final bool stick;
  final Color color;
  final double elevation;
  final Color shadowColor;
  final BubbleEdges padding;
  final BubbleEdges margin;
  final Alignment alignment;
}

class BubbleClipper extends CustomClipper<Path> {
  BubbleClipper({
    this.radius = const Radius.circular(6.0),
    this.nip = BubbleNip.no,
    this.nipWidth = 8.0,
    this.nipHeight = 10.0,
    this.nipOffset = 0.0,
    this.nipRadius = 1.0,
    this.stick = false,
    this.padding = const BubbleEdges.all(8.0),
  });

  final Radius radius;
  final BubbleNip nip;
  final double nipHeight;
  final double nipWidth;
  final double nipOffset;
  final double nipRadius;
  final bool stick;
  final BubbleEdges padding;

  @override
  Path getClip(Size size) {
    var path = Path();
    path.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, radius));
    return path;
  }

  @override
  bool shouldReclip(BubbleClipper oldClipper) => false;
}

class Bubble extends StatelessWidget {
  const Bubble({
    required this.child,
    this.radius = const Radius.circular(6.0),
    this.nip = BubbleNip.no,
    this.nipWidth = 8.0,
    this.nipHeight = 10.0,
    this.nipOffset = 0.0,
    this.nipRadius = 1.0,
    this.stick = false,
    this.color = Colors.white,
    this.elevation = 1.0,
    this.shadowColor = Colors.black,
    this.padding = const BubbleEdges.all(8.0),
    this.margin = const BubbleEdges.all(0.0),
    this.alignment = Alignment.center,
  });

  final Widget child;
  final Radius radius;
  final BubbleNip nip;
  final double nipWidth;
  final double nipHeight;
  final double nipOffset;
  final double nipRadius;
  final bool stick;
  final Color color;
  final double elevation;
  final Color shadowColor;
  final BubbleEdges padding;
  final BubbleEdges margin;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      margin: margin.edgeInsets,
      child: CustomPaint(
        painter: BubblePainter(
          clipper: BubbleClipper(
            radius: radius,
            nip: nip,
            nipWidth: nipWidth,
            nipHeight: nipHeight,
            nipOffset: nipOffset,
            nipRadius: nipRadius,
            stick: stick,
            padding: padding,
          ),
          color: color,
          elevation: elevation,
          shadowColor: shadowColor,
        ),
        child: Container(padding: padding.edgeInsets, child: child),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final CustomClipper<Path> clipper;
  final Color color;
  final double elevation;
  final Color shadowColor;

  BubblePainter({
    required this.clipper,
    required this.color,
    required this.elevation,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (elevation != 0.0) {
      canvas.drawShadow(clipper.getClip(size), shadowColor, elevation, false);
    }
    canvas.drawPath(clipper.getClip(size), paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
