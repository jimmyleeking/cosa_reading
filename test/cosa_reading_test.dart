import 'package:flutter_test/flutter_test.dart';

import 'package:cosa_reading/cosa_reader.dart';

void main() {
  test('adds one to input values', () {
    final reader = COSAReader();
    reader.readFile('./res/customizations.xml');

    var data = reader.getApnList( "01","460");

    data?.forEach((element) {
      print(element.apnList);
    });
  });
}
