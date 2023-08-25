// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

/// This is the shared data in the [ClassDetail].
class ClassDetailState extends InheritedWidget {
  final int currentWeek;
  final List<TimeArrangement> information;
  final List<ClassDetail> classDetail;

  const ClassDetailState({
    super.key,
    required this.currentWeek,
    required this.information,
    required this.classDetail,
    required super.child,
  });

  static ClassDetailState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassDetailState>();
  }

  @override
  bool updateShouldNotify(covariant ClassDetailState oldWidget) {
    return false;
  }
}
