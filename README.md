## About Cosa Reading

一个帮助通过SIM信息获取APN连接点信息的库。数据来源于：
https://learn.microsoft.com/en-us/windows-hardware/drivers/mobilebroadband/cosa-overview

## Quick Start

```dart
    reader.readFile('./res/customizations.xml');

    var data = reader.getApnList( "01","460");
    data?.forEach((element) {
      print(element.apnList);
    });
```

