import 'dart:convert';
import 'dart:typed_data';

import 'package:jtorrent_bencoding/jtorrent_bencoding.dart';

void main() {
  Uint8List charCodes1 = bEncode(12345); // i12345e
  Uint8List charCodes2 = bEncode('12345'); // 5:12345
  Uint8List charCodes3 = bEncode([12345]); // li12345ee
  Uint8List charCodes4 = bEncode({'name': 'JTorrent'}); // d4:name8:JTorrente

  var result1 = bDecode(Utf8Codec().encoder.convert('i666e')); // 666
  var result2 = bDecode(Utf8Codec().encoder.convert('8:JTorrent')); // 'JTorrent'
  var result3 = bDecode(Utf8Codec().encoder.convert('l8:JTorrenti666ee')); //  ['JTorrent', 666]
  var result4 = bDecode(Utf8Codec().encoder.convert('li666ed4:name8:JTorrentee')); // [666, {'name':'JTorrent'}
}
