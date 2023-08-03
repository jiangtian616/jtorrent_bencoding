Bencoding implementation for BitTorrent protocol in pure Dart.

## Usage

### Encode

```dart

Uint8List charCodes = bEncode(12345); // i12345e
Uint8List charCodes = bEncode('12345'); // 5:12345
Uint8List charCodes = bEncode([12345]); // li12345ee
Uint8List charCodes = bEncode({'name': 'JTorrent'}); // d4:name8:JTorrente
```

### Decode

```dart

var result = bDecode(Utf8Codec().encoder.convert('i666e')); // 666
var result = bDecode(Utf8Codec().encoder.convert('8:JTorrent')); // 'JTorrent'.codeUnits
var result = bDecode(Utf8Codec().encoder.convert('l8:JTorrenti666ee')); //  ['JTorrent'.codeUnits, 666]
var result = bDecode(Utf8Codec().encoder.convert('li666ed4:name8:JTorrentee')); // [666, {'name':'JTorrent'.codeUnits}
```