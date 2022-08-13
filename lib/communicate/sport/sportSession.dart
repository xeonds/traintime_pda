/*
Get data from Xidian Sport.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

/* This file is a mess with orders! I need to some sort of cache support. */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:watermeter/dataStruct/sport/punch.dart';
import 'package:encrypt/encrypt.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:watermeter/communicate/general.dart';

// Test only.
import 'package:cookie_jar/cookie_jar.dart';

/// Get base64 encoded data. Which is rsa encrypted [toEnc] using [pubKey].
String rsaEncrypt(String toEnc, String pubKey) {
  dynamic publicKey = RSAKeyParser().parse(pubKey);
  return Encrypter(RSA(publicKey: publicKey)).encrypt(toEnc).base64;
}

class SportSession {

  CookieJar mooncake = CookieJar();

  var username = "";

  var userId = '';

  final _baseURL = 'http://xd.5itsn.com/app/';

  final rsaKey = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq4laolA7zAk7jzsqDb3Oa5pS/uCPlZfASK8Soh/NzEmry77QDZ2koyr96M5Wx+A9cxwewQMHzi8RoOfb3UcQO4UDQlMUImLuzUnfbk3TTppijSLH+PU88XQxcgYm2JTa546c7JdZSI6dBeXOJH20quuxWyzgLk9jAlt3ytYygPQ7C6o6ZSmjcMgE3xgLaHGvixEVpOjL/pdVLzXhrMqWVAnB/snMjpCqesDVTDe5c6OOmj2q5J8n+tzIXtnvrkxQSDaUp8DWF8meMwyTErmYklMXzKic2rjdYZpHh4x98Fg0Q28sp6i2ZoWiGrJDKW29mntVQQiDNhKDawb4B45zUwIDAQAB
-----END PUBLIC KEY-----""";

  final _commonHeader = {
    'channel': 'H5',
    'version': '99999',
    'type': '0',
  };

  static final _commonSignParams = {
    'appId': '3685bc028aaf4e64ad6b5d2349d24ba8',
    'appSecret': 'e8167ef026cbc5e456ab837d9d6d9254'
  };

  String _getSign(Map<String, dynamic> params) {
    var toCalculate = '';
    // Map in dart is not sorted by keys:-O
    for (var i in params.keys.toList()..sort()) {
      toCalculate += "&$i=${params[i]}";
    }
    // sure it is hexString.
    print(toCalculate.substring(1));
    return md5.convert(utf8.encode(toCalculate.substring(1))).toString();
  }

  Map<String, dynamic> _getHead(Map<String, dynamic> payload) {
    Map<String, dynamic> toReturn = _commonHeader;
    toReturn["timestamp"] = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> forSign = payload;
    forSign["timestamp"] = toReturn["timestamp"];
    toReturn['sign'] = _getSign(forSign);
    if (kDebugMode) {
      print("header: $toReturn");
    }
    return toReturn;
  }

  /// Maybe I wrote how to store the data is better.
  Dio get _dio{
    Dio toReturn = Dio(BaseOptions(
      baseUrl: _baseURL,
      contentType: Headers.formUrlEncodedContentType,
    ));
    toReturn.interceptors.add(CookieManager(mooncake));
    return toReturn;
  }

  Future<Map<String,dynamic>> require({
    required String subWebsite,
    required Map<String,dynamic> body,
    bool isForce = false,
  }) async {
    body.addAll(_commonSignParams);
    print("body: $body");
    var response = await _dio.post(
      subWebsite,
      data: body,
      options: Options(
        headers: _getHead(body),
      )
    );
    if (kDebugMode) {
      print(response.data);
      print(await mooncake.loadForRequest(Uri.parse("http://xd.5itsn.com")));
    }
    return response.data;
  }

  Future<void> login ({
    required String username,
    required String password,
  }) async {
    this.username = username;
    var response = await require(
      subWebsite: "/h5/login",
      body: {
        "uname": username,
        "pwd": rsaEncrypt(password,rsaKey),
        "openid": ""
      },
    );
    if (response["returnCode"] != "200") {
      throw "登陆失败：${response["returnMsg"]}";
    } else {
      userId = response["data"]["id"].toString();
      _commonHeader["token"] = response["data"]["token"];
    }
  }

  Future<String> getTermID () async {
    var response = await require(
        subWebsite: "/stuTermPunchRecord/findList",
        body: {
          'userId': userId,
        }
    );
    if (response["returnCode"] == "200"){
      return response["data"][0]["sysTermId"].toString();
    } else {
      throw "获取学期信息失败：${response["returnMsg"]}";
    }

  }

  
  Future<ToStore> getPunchData () async {
    ToStore toReturn = ToStore();
    if (userId == ""){
      await login(username: account, password: password);
    }
    var response = await require(
      subWebsite: "stuPunchRecord/findPager",
      body: {
        'userNum': username,
        'sysTermId': await getTermID(),
        'pageSize': "999",
        'pageIndex': "1"
      },
    );
    /*if (response["returnCode"] != 200 || response["returnCode"] != "200") {
      throw "获取失败：${response["returnMsg"]}";
    }*/
    print(response);
    for (var i in response["data"]){
      toReturn.all.add(PunchData(
          i["machineName"],
          i["weekNum"],
          i["punchDay"],
          i["punchTime"],
          i["state"]
      ));
    }
    toReturn.allTime = response["total"];
    return toReturn;
  }
}

var toUse = SportSession();

Future<ToStore> getPunchData() => toUse.getPunchData();
