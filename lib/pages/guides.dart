import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:sudoku/widgets/guide_viewer.dart';
// TODO: Refactor UI

// TODO: Add localisation somehow???
class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  static const routeName = "/guides";
  static const path = "assets/guides/";

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  late final Future<String> guideList;

  @override
  void initState() {
    super.initState();
    guideList = rootBundle.loadString("AssetManifest.json");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("guides.name".i18n())),
      body: SafeArea(
        child: FutureBuilder(
          future: guideList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<String> guides = json
                  .decode(snapshot.data ?? "")
                  .keys
                  .where((String key) => key.startsWith(GuidesPage.path))
                  .toList();

              return ListView(
                children: [
                  for (String guide in guides)
                    TextButton(
                      child: Text(guide.toTechniqueName()),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GuideViewer(
                            title: guide.toTechniqueName(),
                            path: guide,
                          ),
                        ));
                      },
                    ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("general.error".i18n([snapshot.error.toString()]));
            } else {
              return Text("general.loading".i18n());
            }
          },
        ),
      ),
    );
  }
}

extension _Converters on String {
  String snakeCasetoSentenceCase() {
    return "${this[0].toUpperCase()}${substring(1)}"
        .replaceAll(RegExp(r'(_|-)+'), ' ');
  }

  String toTechniqueName() {
    return replaceFirst(GuidesPage.path, "")
        .snakeCasetoSentenceCase()
        .split(".")[0];
  }
}
