import 'package:boorusama/application/download/post_download_state_notifier.dart';
import 'package:boorusama/application/post_detail/notes/notes_state_notifier.dart';
import 'package:boorusama/application/post_detail/post/post_detail_state_notifier.dart';
import 'package:boorusama/application/post_detail/post/post_view_model.dart';
import 'package:boorusama/application/post_detail/tags/tags_state_notifier.dart';
import 'package:boorusama/domain/posts/note.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/post_detail/post_info_page.dart';
import 'package:boorusama/presentation/post_detail/widgets/post_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'widgets/post_note.dart';
import 'widgets/post_image.dart';

final postDownloadStateNotifierProvider =
    StateNotifierProvider<PostDownloadStateNotifier>(
        (ref) => PostDownloadStateNotifier(ref));

final notesStateNotifierProvider =
    StateNotifierProvider<NotesStateNotifier>((ref) => NotesStateNotifier(ref));

final postDetailStateNotifierProvider =
    StateNotifierProvider<PostDetailStateNotifier>(
        (ref) => PostDetailStateNotifier(ref));

final tagsStateNotifierProvider =
    StateNotifierProvider<TagsStateNotifier>((ref) => TagsStateNotifier(ref));

class PostDetailPage extends StatefulWidget {
  PostDetailPage({
    Key key,
    @required this.postId,
  }) : super(key: key);

  final int postId;

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  double _bodyHeight;
  PanelController _panelController = PanelController();
  bool _notesVisible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
        () => context
            .read(postDetailStateNotifierProvider)
            .getPost(widget.postId));

    Future.delayed(Duration.zero,
        () => context.read(notesStateNotifierProvider).getNotes(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    _bodyHeight ??= (MediaQuery.of(context).size.height -
            kToolbarHeight -
            60 -
            MediaQuery.of(context).padding.top) *
        1;

    return WillPopScope(
      onWillPop: () {
        context.read(notesStateNotifierProvider).clearNotes();
        return Future.value(true);
      },
      child: ProviderListener<PostDetailState>(
        provider: postDetailStateNotifierProvider.state,
        onChange: (context, state) {
          state.maybeWhen(
              fetched: (post) => context
                  .read(tagsStateNotifierProvider)
                  .getTags(post.tagString.toCommaFormat()),
              orElse: () {});
        },
        child: Consumer(
          builder: (context, watch, child) {
            final state = watch(postDetailStateNotifierProvider.state);
            return state.when(
              initial: () => _buildLoading(context),
              loading: () => _buildLoading(context),
              fetched: (post) {
                if (post.isVideo) {
                  final postVideo = Hero(
                      tag: "${post.id}",
                      child: PostVideo(
                          videoSourceUrl: post.mediumResSource,
                          aspectRatio: post.aspectRatio));
                  return _buildPage(context, post, postVideo);
                } else {
                  final postImage = Hero(
                      tag: "${post.id}",
                      child: PostImage(imageUrl: post.mediumResSource));
                  return _buildPage(context, post, postImage);
                }
              },
              error: (name, message) => Center(
                child: Text(message),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 10.0, left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle1),
                Text("",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption),
              ],
            ),
          ),
          actions: <Widget>[
            PopupMenuButton<PostAction>(
              onSelected: (value) {
                switch (value) {
                  case PostAction.download:
                    // context.read<PostDownloadBloc>().add(
                    //       PostDownloadEvent.downloaded(
                    //         post: widget.posts[_currentPostIndex],
                    //       ),
                    //     );
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PostAction>>[
                PopupMenuItem<PostAction>(
                  value: PostAction.download,
                  child: ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text("Download"),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, PostViewModel post, Widget postWidget) {
    var appbarActions = <Widget>[];

    if (post.isTranslated) {
      appbarActions.add(IconButton(
          icon: Icon(Icons.translate),
          onPressed: () {
            setState(() {
              _notesVisible = !_notesVisible;
            });
          }));
    }

    appbarActions.add(
      PopupMenuButton<PostAction>(
        onSelected: (value) {
          switch (value) {
            case PostAction.download:
              context
                  .read(postDownloadStateNotifierProvider)
                  .download(post.downloadLink, post.descriptiveName);
              break;
            default:
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
          PopupMenuItem<PostAction>(
            value: PostAction.download,
            child: ListTile(
              leading: const Icon(Icons.download_rounded),
              title: Text("Download"),
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 10.0, left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.copyrights,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle1),
                Text(post.characters,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption),
              ],
            ),
          ),
          actions: appbarActions,
        ),
        body: Consumer(
          builder: (context, watch, child) {
            final state = watch(notesStateNotifierProvider.state);
            final widgets = state.maybeWhen(
              fetched: (notes) => buildNotes(notes, post),
              orElse: () => [Center()],
            );

            return SlidingUpPanel(
              controller: _panelController,
              bodyHeight: _bodyHeight,
              maxHeight: (MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top) *
                  0.65,
              minHeight: 60,
              panel: Consumer(
                builder: (context, watch, child) {
                  final state = watch(tagsStateNotifierProvider.state);
                  return state.maybeWhen(
                      fetched: (tags) => PostInfoPage(post: post, tags: tags),
                      orElse: () => PostInfoPage(post: post, tags: <Tag>[]));
                },
                child: PostInfoPage(post: null, tags: null),
              ),
              body: Stack(
                children: <Widget>[
                  postWidget,
                  if (_notesVisible) ...widgets,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> buildNotes(List<Note> notes, PostViewModel post) {
    final widgets = List<Widget>();

    final screenWidth = MediaQuery.of(context).size.width;
    //TODO: Can't get status bar height inside Scaffold
    final screenHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        24 -
        60; // minus toolbar height, status bar height and custom value for the bottom sheet;
    final screenAspectRatio = screenWidth / screenHeight;

    for (var note in notes) {
      final coordinate = note.coordinate.calibrate(screenHeight, screenWidth,
          screenAspectRatio, post.height, post.width, post.aspectRatio);

      widgets.add(
        PostNote(
          coordinate: coordinate,
          content: note.content,
          targetContext: context,
        ),
      );
    }

    return widgets;
  }
}

enum PostAction { download }
