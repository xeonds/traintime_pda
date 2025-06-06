// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Python script by arttnba3

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EasterEggPage extends StatefulWidget {
  const EasterEggPage({super.key});

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  // Ommadawn
  final String urlOthers = "https://www.bilibili.com/video/BV1s44y1S7DW/";

  // The Invisible Sun - The Police - Ghosts in the Machine
  final String urlApple = "https://www.bilibili.com/video/BV1LE411e7n1/?p=10";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            "setting.easter_egg_page",
          ),
        ),
      ),
      body: [
        [
          IconButton.filledTonal(
            onPressed: () => launchUrl(
              Uri.parse(
                Platform.isIOS || Platform.isMacOS ? urlApple : urlOthers,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
          const SizedBox(width: 24),
          IconButton.filledTonal(
            onPressed: () => launchUrl(
              Uri.parse(
                Platform.isIOS || Platform.isMacOS ? urlOthers : urlApple,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(all: 24.0),
        Text(
          FlutterI18n.translate(
            context,
            Platform.isIOS || Platform.isMacOS
                ? "easter_egg_apple"
                : "easter_egg_others",
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Image.asset("assets/art/pda_girl_default.png"),
        Text("The sun shall rose to the destination "
            "where all of us enjoys the happiness."),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
          .scrollable()
          .center()
          .padding(horizontal: 16)
          .safeArea(),
    );
  }
}
