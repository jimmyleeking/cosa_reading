library cosa_reading;

import 'dart:io';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';
import 'package:xml2json/xml2json.dart';

class APNInfo {
  /// 连接点名称
  String? accessPointName;

  /// 是否总是默认打开
  bool alwaysOn = false;

  /// 友好的显示名称
  String? friendlyName;

  /// ip类型
  String? iPType;

  /// 密码
  String? password;
}

class CosaItem {
  /// SIM的MCC
  String mcc = "";

  /// SIM的MNC
  String mnc = "";

  /// 显示到UI界面的名称
  String? uiName;

  String? uiOrder;

  String? iMSI;
  String? sPN;
  String? targetId;
  List<APNInfo> apnList = [];
}

class COSAReader {
  final myTransformer = Xml2Json();
  String lastFilePath = "";

  late Map<String, List<CosaItem>> dataMap;

  /// 获取APN的列表 <br>
  /// [mnc] SIMCard MNC info <br>
  /// [mcc] SIMCard MCC info
  List<CosaItem>? getApnList(String mnc, String mcc) {
    String key = _getMapKey(mnc, mcc);
    if (dataMap[key] == null) {
      dataMap[key] = [];
    }
    return dataMap[key];
  }

  void readFile(String filePath) {
    if (lastFilePath == filePath) {
      return;
    }
    dataMap = {};
    var file = File(filePath);
    var contents = file.readAsStringSync();
    var document = XmlDocument.parse(contents);

    document
        .xpath('//Target[TargetState/Condition[@Name="Mcc"]]')
        .forEach((element) {
      String id = element.getAttribute("Id") ?? "";

      List<APNInfo> apnList = [];
      var xpath4Profile = '//Profile[TargetRefs/TargetRef[@Id="$id"]]';
      document.xpath(xpath4Profile).forEach((connectionElement) {
        connectionElement.findAllElements("Connection").forEach((node) {
          APNInfo info = new APNInfo();
          info.accessPointName = _getConnectionValue(node, "AccessPointName");
          String isOn = _getConnectionValue(node, "AlwaysOn") ?? "";
          if (isOn != "") {
            info.alwaysOn = isOn == "Enabled" ? true : false;
          }
          info.iPType = _getConnectionValue(node, "IPType");
          info.friendlyName = _getConnectionValue(node, "FriendlyName");
          info.password = _getConnectionValue(node, "Password");
          apnList.add(info);
        });
      });
      element.findAllElements("TargetState").forEach((elementItem) {
        CosaItem item = new CosaItem();
        item.mcc = _getValue(elementItem, "Mcc")!;
        item.mnc = _getValue(elementItem, "Mnc")!;
        item.uiName = _getValue(elementItem, "uiname");
        item.uiOrder = _getValue(elementItem, "uiorder");
        item.iMSI = _getValue(elementItem, "IMSI");
        item.sPN = _getValue(elementItem, "SPN");
        item.targetId = id;
        item.apnList = apnList;
        if (item.mnc != "" && item.mcc != "") {
          String key = _getMapKey(item.mnc, item.mcc);
          if (dataMap[key] == null) {
            dataMap[key] = [];
          }
          print(key);
          dataMap[key]?.add(item);
        }
      });
    });
  }

  String _getMapKey(String mnc, String mcc) {
    String key = mnc + "_" + mcc;
    return key;
  }

  /// 获取连接信息
  String? _getConnectionValue(XmlNode node, String name) {
    return node.findElements(name).firstOrNull?.innerText;
  }

  /// 获取Element的值 [name] attribute的名称
  String? _getValue(XmlNode elementItem, String name) {
    String value = "";
    elementItem.findAllElements("Condition").forEach((element) {
      if (element.getAttribute("Name").toString() == name) {
        value = element.getAttribute("Value").toString();
      }
    });
    return value;
  }
}
