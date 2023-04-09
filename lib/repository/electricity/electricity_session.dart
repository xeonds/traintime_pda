/*
Get electricity usage data.

Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.

Thanks xidian-script!
*/

import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/user.dart';
import 'package:watermeter/repository/general.dart';

// ignore: constant_identifier_names
const BASE = "http://10.168.55.50:8088";

Future<String> electricitySession({required String username}) async {
  Dio dio = Dio();

  if (await isInSchool() == false) {
    return "没有在校园网环境";
  }

  // ASP session id.
  var sessionId = await dio
      .get("$BASE/searchWap/Login.aspx")
      .then((value) => value.headers.map["Set-Cookie"]![0]);
  sessionId = sessionId.substring(0, 42);

  developer.log(
    sessionId,
    name: "ElectricSession",
  );

  await dio
      .post(
        "$BASE/ajaxpro/SearchWap_Login,App_Web_fghipt60.ashx",
        data: {
          "webName": username,
          "webPass": user["electricityPassword"]!,
        },
        options: Options(headers: {
          "AjaxPro-Method": "getLoginInput",
          "Cookie": sessionId,
          'Origin': "$BASE/ajaxpro/SearchWap_Login,App_Web_fghipt60.ashx",
        }),
      )
      .then((value) => value.data.toString());

  var page = await dio
      .get("$BASE/searchWap/webFrm/met.aspx",
          options: Options(headers: {"Cookie": sessionId}))
      .then((value) => value.data);

  developer.log(
    page,
    name: "ElectricSession",
  );

  RegExp name = RegExp(r"表名称：.*");
  RegExp data = RegExp(r"剩余量：.*");
  RegExp info = RegExp(r"安装位置：.*");

  List<RegExpMatch> nameArray = name.allMatches(page).toList();
  List<RegExpMatch> dataArray = data.allMatches(page).toList();
  List<RegExpMatch> infoArray = info.allMatches(page).toList();

  for (int i = 0; i < nameArray.length; ++i) {
    if (nameArray[i][0]!.contains("电表") && infoArray[i][0]!.contains("房间")) {
      return dataArray[i][0]!.substring(4);
    }
  }

  return "无法获取";
}