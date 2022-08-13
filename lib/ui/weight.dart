/*
Useful weight to simplify watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';

/// Use it as the larger boxes.
class ShadowBox extends StatelessWidget {
  final Widget child;

  const ShadowBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      //color: Colors.deepPurple,
      elevation: 20.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      semanticContainer: false,
      child: child,
    );
  }
}

/// Use it to show the small items.
class TagsBoxes extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const TagsBoxes({
    Key? key,
    required this.text,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}

/// Use it at the top of each page
class TitleLine extends StatelessWidget {
  final Widget child;

  const TitleLine({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 0.1,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
        child: child,
    );
  }
}