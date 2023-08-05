import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:jtorrent_bencoding/src/jtorrent_bencoding_base.dart';
import 'package:test/test.dart';

void main() {
  group('Test Encoding', () {
    test('Encode number 0', () {
      assert(utf8.decode(bEncode(0)) == 'i0e');
    });

    test('Encode number 12345', () {
      assert(utf8.decode(bEncode(12345)) == 'i12345e');
    });

    test('Encode number -12345', () {
      assert(utf8.decode(bEncode(-12345)) == 'i-12345e');
    });

    test('Encode string 0', () {
      assert(utf8.decode(bEncode('0')) == '1:0');
    });

    test('Encode string 12345', () {
      assert(utf8.decode(bEncode('12345')) == '5:12345');
    });

    test('Encode string -12345', () {
      assert(utf8.decode(bEncode('-12345')) == '6:-12345');
    });

    test('Encode string JTorrent', () {
      assert(utf8.decode(bEncode('JTorrent')) == '8:JTorrent');
    });

    test('Encode string ab in UInt8List', () {
      assert(ListEquality().equals(bEncode(utf8.encode('ab')), Uint8List.fromList([50, 58, 97, 98])));
    });

    test('Encode empty list', () {
      assert(utf8.decode(bEncode([])) == 'le');
    });

    test('Encode list', () {
      assert(utf8.decode(bEncode([
            [1, -2],
            [
              ['-1', '-2'],
              [true, false]
            ]
          ])) ==
          'lli1ei-2eell2:-12:-2eli1ei0eeee');
    });

    test('Encode empty map', () {
      assert(utf8.decode(bEncode({})) == 'de');
    });

    test('Encode map', () {
      assert(utf8.decode(bEncode({'name': 'jTorrent', '2name': '2jTorrent'})) == 'd5:2name9:2jTorrent4:name8:jTorrente');
    });

    test('Encode map and list', () {
      assert(utf8.decode(bEncode({
            'names': ['JTorrent']
          })) ==
          'd5:namesl8:JTorrentee');
    });
  });

  group('Tests Decoding', () {
    test('Test integer 666', () {
      assert(bDecode(Utf8Codec().encoder.convert('i666e')) == 666);
    });

    test('Test integer -666', () {
      assert(bDecode(Utf8Codec().encoder.convert('i-666e')) == -666);
    });

    test('Test integer +666', () {
      assert(bDecode(Utf8Codec().encoder.convert('i+666e')) == 666);
    });

    test('Test integer 0', () {
      assert(bDecode(Utf8Codec().encoder.convert('i0e')) == 0);
    });

    test('Test string JTorrent', () {
      assert(ListEquality().equals(
        bDecode(Utf8Codec().encoder.convert('8:JTorrent')),
        utf8.encode('JTorrent'),
      ));
    });

    test('Test string 127.0.0.1', () {
      assert(ListEquality().equals(
        bDecode(Utf8Codec().encoder.convert('9:127.0.0.1')),
        utf8.encode('127.0.0.1'),
      ));
    });

    test('Test string localhost:80', () {
      assert(ListEquality().equals(
        bDecode(Utf8Codec().encoder.convert('12:localhost:80')),
        utf8.encode('localhost:80'),
      ));
    });

    test('Test string ab in UInt8List', () {
      assert(ListEquality().equals(bDecode(bEncode(utf8.encode('ab'))), utf8.encode('ab')));
    });

    test('Test list', () {
      assert(DeepCollectionEquality().equals(
        bDecode(Utf8Codec().encoder.convert('l8:JTorrenti666ee')),
        [utf8.encode('JTorrent'), 666],
      ));
    });

    test('Test list', () {
      assert(DeepCollectionEquality().equals(
        bDecode(Utf8Codec().encoder.convert('l8:JTorrenti666el8:JTorrenti666eee')),
        [
          utf8.encode('JTorrent'),
          666,
          [utf8.encode('JTorrent'), 666],
        ],
      ));
    });

    test('Test empty list', () {
      assert(DeepCollectionEquality().equals(
        bDecode(Utf8Codec().encoder.convert('llelleleee')),
        [
          [],
          [[], []]
        ],
      ));

      assert(DeepCollectionEquality().equals(
        bDecode(Utf8Codec().encoder.convert('llelleleellleeee')),
        [
          [],
          [[], []],
          [
            [[]]
          ],
        ],
      ));
    });

    test('Test map', () {
      assert(DeepCollectionEquality().equals(
        bDecode(Utf8Codec().encoder.convert('d5:2name9:2JTorrent4:name8:JTorrent5:piecei5e4:listld4:name8:JTorrenteee')),
        {
          '2name': utf8.encode('2JTorrent'),
          'name': utf8.encode('JTorrent'),
          'piece': 5,
          'list': [
            {'name': utf8.encode('JTorrent')}
          ]
        },
      ));
    });

    test('Test map', () {
      assert(DeepCollectionEquality().equals(
        bDecode(Utf8Codec().encoder.convert('li666ed4:name8:JTorrentee')),
        [
          666,
          {'name': utf8.encode('JTorrent')}
        ],
      ));
    });

    test('Test empty map', () {
      assert(DeepCollectionEquality().equals(
        bDecode(Utf8Codec().encoder.convert('de')),
        {},
      ));
    });
  });
}
