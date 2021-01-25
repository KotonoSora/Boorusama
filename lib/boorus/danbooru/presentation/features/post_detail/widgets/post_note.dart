// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:super_tooltip/super_tooltip.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/note_coordinate.dart';

class PostNote extends StatelessWidget {
  const PostNote({
    Key key,
    @required this.coordinate,
    @required this.content,
    @required this.targetContext,
  }) : super(key: key);

  final NoteCoordinate coordinate;
  final String content;
  final BuildContext targetContext;

  @override
  Widget build(BuildContext context) {
    TooltipDirection direction;
    if (coordinate.x > MediaQuery.of(context).size.width / 2) {
      direction = TooltipDirection.left;
    } else {
      direction = TooltipDirection.right;
    }

    var tooltip = SuperTooltip(
      backgroundColor: Theme.of(context).cardColor,
      arrowTipDistance: 0,
      arrowBaseWidth: 0,
      arrowLength: 0,
      popupDirection: direction,
      content: Material(
        child: Html(data: content),
        color: Theme.of(context).cardColor,
      ),
    );
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => tooltip.show(targetContext),
        child: Container(
          margin: EdgeInsets.only(left: coordinate.x, top: coordinate.y),
          width: coordinate.width,
          height: coordinate.height,
          decoration: BoxDecoration(
              color: Colors.white54,
              border: Border.all(color: Colors.red, width: 1)),
        ),
      ),
    );
  }
}
