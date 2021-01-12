import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/application/themes/bloc/theme_bloc.dart';
import 'package:boorusama/application/wikis/wiki/bloc/wiki_bloc.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/domain/comments/i_comment_repository.dart';
import 'package:boorusama/domain/posts/i_note_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/users/i_user_repository.dart';
import 'package:boorusama/domain/wikis/i_wiki_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/presentation/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/all.dart';

import 'application/authentication/bloc/authentication_bloc.dart';
import 'application/comments/bloc/comment_bloc.dart';
import 'application/users/bloc/user_list_bloc.dart';
import 'application/users/user/bloc/user_bloc.dart';
import 'infrastructure/repositories/settings/setting.dart';

class App extends StatefulWidget {
  App({
    @required this.postRepository,
    @required this.downloadService,
    @required this.tagRepository,
    @required this.noteRepository,
    @required this.favoritePostRepository,
    @required this.accountRepository,
    @required this.userRepository,
    @required this.settingRepository,
    @required this.wikiRepository,
    @required this.commentRepository,
    this.settings,
  });

  final IPostRepository postRepository;
  final ITagRepository tagRepository;
  final INoteRepository noteRepository;
  final IAccountRepository accountRepository;
  final IDownloadService downloadService;
  final IFavoritePostRepository favoritePostRepository;
  final ICommentRepository commentRepository;
  final IUserRepository userRepository;
  final ISettingRepository settingRepository;
  final IWikiRepository wikiRepository;
  final Setting settings;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostDownloadBloc>(
          lazy: false,
          create: (_) => PostDownloadBloc(widget.downloadService)
            ..add(
              PostDownloadEvent.init(platform: Theme.of(context).platform),
            ),
        ),
        BlocProvider<TagListBloc>(
            create: (_) => TagListBloc(widget.tagRepository)),
        BlocProvider<PostFavoritesBloc>(
            create: (_) => PostFavoritesBloc(
                  widget.postRepository,
                  widget.favoritePostRepository,
                  widget.settingRepository,
                )),
        BlocProvider<CommentBloc>(
            create: (_) =>
                CommentBloc(commentRepository: widget.commentRepository)),
        BlocProvider<UserListBloc>(
            create: (_) => UserListBloc(widget.userRepository)),
        BlocProvider<UserBloc>(
          lazy: false,
          create: (_) => UserBloc(
            accountRepository: widget.accountRepository,
            userRepository: widget.userRepository,
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            settingRepository: widget.settingRepository,
          ),
        ),
        BlocProvider<WikiBloc>(create: (_) => WikiBloc(widget.wikiRepository)),
        BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc()
              ..add(ThemeChanged(theme: widget.settings.themeMode))),
      ],
      child: BlocConsumer<ThemeBloc, ThemeState>(
        listener: (context, state) {
          // WidgetsBinding.instance.addPostFrameCallback((_) async {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: state.appBarColor,
              statusBarBrightness: state.statusBarIconBrightness,
              statusBarIconBrightness: state.statusBarIconBrightness));
          // });
        },
        builder: (context, state) {
          return ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                primaryTextTheme: Theme.of(context)
                    .textTheme
                    .copyWith(headline6: TextStyle(color: Colors.black)),
                appBarTheme: AppBarTheme(
                    brightness: state.appBarBrightness,
                    iconTheme: IconThemeData(color: state.iconColor),
                    color: state.appBarColor),
                iconTheme: IconThemeData(color: state.iconColor),
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                primaryTextTheme: Theme.of(context)
                    .textTheme
                    .copyWith(headline6: TextStyle(color: Colors.white)),
                appBarTheme: AppBarTheme(
                    brightness: state.appBarBrightness,
                    iconTheme: IconThemeData(color: state.iconColor),
                    color: state.appBarColor),
                iconTheme: IconThemeData(color: state.iconColor),
                brightness: Brightness.dark,
              ),
              themeMode: state.theme,
              debugShowCheckedModeBanner: false,
              title: "Boorusama",
              home: HomePage(),
            ),
          );
        },
      ),
    );
  }
}
