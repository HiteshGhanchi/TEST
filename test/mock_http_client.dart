
import 'dart:async';
import 'dart:io';

// A mock HTTP client that always returns a transparent image.
class MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }

  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> transformer) {
    // A 1x1 transparent pixel GIF
    const List<int> transparentImage = [
      0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x21, 0xf9, 0x04, 0x01, 0x00,
      0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
      0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b
    ];
    return Stream.value(transparentImage).transform(transformer);
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, List<int>) combine) {
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
