import 'dart:convert';
import 'dart:typed_data';

import '../jtorrent_bencoding.dart';

/// http://bittorrent.org/beps/bep_0003.html

/// Encode int/String/bool/List/Map to Uint8List
Uint8List bEncode(dynamic data) {
  return _BEncoder(data).encode();
}

/// Decode Uint8List to int/Uint8List(String)/List/Map/null
dynamic bDecode(Uint8List data) {
  if (data.isEmpty) {
    return null;
  }
  return _BDecoder(data).decode();
}

class _BEncoder {
  final dynamic _data;

  final Uint8List buffI = Uint8List.fromList(utf8.encode('i'));
  final Uint8List buffE = Uint8List.fromList(utf8.encode('e'));
  final Uint8List buffL = Uint8List.fromList(utf8.encode('l'));
  final Uint8List buffD = Uint8List.fromList(utf8.encode('d'));

  _BEncoder(this._data);

  Uint8List encode() {
    return _encode(_data);
  }

  Uint8List _encode(dynamic data) {
    if (data == null) {
      return Uint8List.fromList([]);
    }

    if (data is int) {
      return _encodeInteger(data);
    }
    if (data is String) {
      return _encodeString(data);
    }
    if (data is Uint8List) {
      return _encodeStringInUint8List(data);
    }
    if (data is bool) {
      return _encodeInteger(data ? 1 : 0);
    }
    if (data is List) {
      return _encodeList(data);
    }
    if (data is Map) {
      return _encodeMap(data);
    }

    throw BEncodingException('Unsupported type: ${data.runtimeType}');
  }

  Uint8List _encodeInteger(num num) {
    return Uint8List.fromList(utf8.encode('i${num}e'));
  }

  Uint8List _encodeString(String str) {
    return Uint8List.fromList(utf8.encode('${str.length}:$str'));
  }

  Uint8List _encodeStringInUint8List(Uint8List str) {
    List<int> result = [];
    result.addAll(utf8.encode('${str.length}:'));
    result.addAll(str);
    return Uint8List.fromList(result);
  }

  Uint8List _encodeList(List list) {
    List<int> result = [];

    result.addAll(buffL);
    for (dynamic element in list) {
      if (element == null) {
        continue;
      }
      result.addAll(_encode(element));
    }
    result.addAll(buffE);

    return Uint8List.fromList(result);
  }

  Uint8List _encodeMap(Map map) {
    List keys = map.keys.toList()..sort();
    List<int> result = [];

    result.addAll(buffD);
    for (dynamic key in keys) {
      if (key == null || key is! String || map[key] == null) {
        continue;
      }
      result.addAll(_encode(key));
      result.addAll(_encode(map[key]));
    }
    result.addAll(buffE);

    return Uint8List.fromList(result);
  }
}

class _BDecoder {
  static const int iChar = 0x69;
  static const int lChar = 0x6C;
  static const int dChar = 0x64;
  static const int eChar = 0x65;
  static const int colonChar = 0x3A;

  final Uint8List _data;
  int _position = 0;

  _BDecoder(this._data);

  dynamic decode() {
    if (_data.isEmpty) {
      return null;
    }

    switch (_data[_position]) {
      case iChar:
        return _decodeInteger();
      case lChar:
        return _decodeList();
      case dChar:
        return _decodeMap();
      default:
        return _decodeString();
    }
  }

  int _decodeInteger() {
    int startPosition = _position + 1;
    int endPosition = _findNextChar(eChar);
    _position = endPosition + 1;
    return _decodeIntegerFromPosition(startPosition, endPosition);
  }

  /// Decode to utf-8 string if possible, otherwise return Uint8List
  dynamic _decodeString() {
    int lengthStartPosition = _position;
    int lengthEndPosition = _findNextChar(colonChar);
    int length = _decodeIntegerFromPosition(lengthStartPosition, lengthEndPosition);

    int strStartPosition = lengthEndPosition + 1;
    int strEndPosition = strStartPosition + length;

    _position = strEndPosition;

    Uint8List uint8list = _data.sublist(strStartPosition, strEndPosition);
    try {
      return utf8.decode(uint8list);
    } catch (e) {
      return uint8list;
    }
  }

  List _decodeList() {
    _position++;

    List list = [];
    while (_data[_position] != eChar) {
      list.add(decode());
    }

    _position++;
    return list;
  }

  Map<String, dynamic> _decodeMap() {
    _position++;

    Map<String, dynamic> map = {};
    while (_data[_position] != eChar) {
      dynamic key = _decodeString();
      map[key is String ? key : String.fromCharCodes(key)] = decode();
    }

    _position++;
    return map;
  }

  int _findNextChar(int character) {
    int i = _position;
    while (i < _data.length) {
      if (_data[i] == character) return i;
      i++;
    }

    throw BDecodingException(
        'BDecode failed, invalid data. Missing character "${String.fromCharCode(character)}" from $_position to ${_data.length}');
  }

  int _decodeIntegerFromPosition(int start, int end) {
    String str = utf8.decode(_data.sublist(start, end));
    int? number = int.tryParse(str);
    if (number == null) {
      throw BDecodingException('BDecode failed, invalid integer: "$str" in [$start, $end]]');
    }
    return number;
  }
}
