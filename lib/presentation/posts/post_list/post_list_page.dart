import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/post_list_page_view.dart';
import 'package:boorusama/presentation/services/debouncer/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PostListPage extends StatefulWidget {
  PostListPage({Key key}) : super(key: key);

  @override
  PostListPageState createState() => PostListPageState();
}

class PostListPageState extends State<PostListPage> {
  String _currentSearchQuery = "";
  int _currentPage = 1;
  int currentTab = 0;
  final List<Post> posts = List<Post>();
  final ScrollController scrollController = new ScrollController();
  final FloatingSearchBarController searchBarController =
      FloatingSearchBarController();
  final Debouncer _debouncer = Debouncer();

  Account account;

  @override
  void initState() {
    super.initState();
    context.read<PostListBloc>().add(GetPost("", 1));
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchBarController.dispose();
    super.dispose();
  }

  void handleSearched(String query) {
    _currentSearchQuery = query;
    _currentPage = 1;
    posts.clear();
    context
        .read<PostListBloc>()
        .add(GetPost(_currentSearchQuery, _currentPage));
    scrollController.jumpTo(0.0);
  }

  void handleTabChanged(int tabIndex) {
    setState(() {
      currentTab = tabIndex;
    });
  }

  void loadMorePosts(_) {
    _debouncer(() {
      _currentPage++;
      context
          .read<PostListBloc>()
          .add(GetMorePost(_currentSearchQuery, _currentPage));
    });
  }

  void downloadAllPosts() {
    posts.forEach((post) {
      context.read<PostDownloadBloc>().add(PostDownloadRequested(post: post));
    });
  }

  void assignAccount(Account account) {
    setState(() {
      this.account = account;
    });
  }

  void removeAccount(Account account) {
    //TODO: dirty solution, unused parameter
    setState(() {
      this.account = null;
    });
  }

  void assignTagQuery(String query) {
    _currentSearchQuery = query;
    searchBarController.query = query;
  }

  @override
  Widget build(BuildContext context) => PostListPageView(this);
}
