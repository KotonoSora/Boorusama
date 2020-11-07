import 'package:boorusama/application/users/user/bloc/user_bloc.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/presentation/settings/tag_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ISettingRepository _settingRepository;
  Setting _setting = Setting(false, "");

  @override
  void initState() {
    super.initState();
    _settingRepository = Provider.of<SettingRepository>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final setting = await _settingRepository.load();
      setState(() {
        _setting = setting;
      });
    });
  }

  @override
  void dispose() {
    _settingRepository.save(_setting);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserFetched) {
            _setting.blacklistedTags = state.user.blacklistedTags.join("\n");
          }
        },
        child: SettingsList(
          sections: [
            SettingsSection(tiles: [
              SettingsTile.switchTile(
                  title: "Safe mode",
                  onToggle: (value) {
                    setState(() {
                      _setting.safeMode = value;
                    });
                  },
                  switchValue: _setting.safeMode),
              SettingsTile(
                title: "Blacklisted tags",
                onTap: () {
                  BlocProvider.of<UserBloc>(context).add(UserRequested());

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => TagSettingsPage()));
                },
              )
            ]),
          ],
        ),
      ),
    );
  }
}