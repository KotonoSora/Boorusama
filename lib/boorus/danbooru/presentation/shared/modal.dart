// Flutter imports:
import 'package:flutter/material.dart';

class Modal extends StatelessWidget {
  const Modal({
    this.title,
    @required this.child,
  });

  final Widget child;
  final String title;

  static const Radius _borderRadius = Radius.circular(30.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: _borderRadius,
          topRight: _borderRadius,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _DragLine(),
          _Title(title),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _DragLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.2;

    return Container(
      width: width,
      height: 3,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: Theme.of(context).accentColor,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 18,
        bottom: 8,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
