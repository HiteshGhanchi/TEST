
import 'dart:io';

import 'package:mockito/mockito.dart';

class MockFile extends Mock implements File {
  @override
  Future<File> writeAsBytes(List<int> bytes, {FileMode mode = FileMode.write, bool flush = false}) =>
      super.noSuchMethod(
        Invocation.method(#writeAsBytes, [bytes], {#mode: mode, #flush: flush}),
        returnValue: Future.value(MockFile()),
      );
}
