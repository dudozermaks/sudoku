import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:sudoku/widgets/guide_viewer.dart';

// TODO: Add localisation somehow???
class Guides extends StatefulWidget {
  const Guides({super.key});

  static const routeName = "/guides";
  static const path = "assets/guides/";

  @override
  State<Guides> createState() => _GuidesState();
}

class _GuidesState extends State<Guides> {
  late final Future<String> guideList;

  @override
  void initState() {
    super.initState();
    guideList = rootBundle.loadString("AssetManifest.json");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("guides".i18n())),
      body: SafeArea(
        child: FutureBuilder(
          future: guideList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<String> guides = json
                  .decode(snapshot.data ?? "")
                  .keys
                  .where((String key) => key.startsWith(Guides.path))
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
              return Text("error".i18n([snapshot.error.toString()]));
            } else {
              return Text("loading".i18n());
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
    return replaceFirst(Guides.path, "")
        .snakeCasetoSentenceCase()
        .split(".")[0];
  }
}
