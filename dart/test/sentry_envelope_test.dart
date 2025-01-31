import 'dart:convert';

import 'package:sentry/sentry.dart';
import 'package:sentry/src/sentry_envelope.dart';
import 'package:sentry/src/sentry_envelope_header.dart';
import 'package:sentry/src/sentry_envelope_item_header.dart';
import 'package:sentry/src/sentry_envelope_item.dart';
import 'package:sentry/src/sentry_item_type.dart';
import 'package:sentry/src/protocol/sentry_id.dart';
import 'package:test/test.dart';

void main() {
  group('SentryEnvelope', () {
    test('serialize', () async {
      final eventId = SentryId.newId();

      final itemHeader =
          SentryEnvelopeItemHeader(SentryItemType.event, () async {
        return 9;
      }, contentType: 'application/json');

      final dataFactory = () async {
        return utf8.encode('{fixture}');
      };

      final item = SentryEnvelopeItem(itemHeader, dataFactory);

      final header = SentryEnvelopeHeader(eventId, null);
      final sut = SentryEnvelope(header, [item, item]);

      final expectedHeaderJson = header.toJson();
      final expectedHeaderJsonSerialized = jsonEncode(expectedHeaderJson);

      final expectedItem = await item.envelopeItemStream();
      final expectedItemSerialized = utf8.decode(expectedItem);

      final expected = utf8.encode(
          '$expectedHeaderJsonSerialized\n$expectedItemSerialized\n$expectedItemSerialized');

      final envelopeData = <int>[];
      await sut.envelopeStream().forEach(envelopeData.addAll);
      expect(envelopeData, expected);
    });

    test('fromEvent', () async {
      final eventId = SentryId.newId();
      final sentryEvent = SentryEvent(eventId: eventId);
      final sdkVersion =
          SdkVersion(name: 'fixture-name', version: 'fixture-version');
      final sut = SentryEnvelope.fromEvent(sentryEvent, sdkVersion);

      final expectedEnvelopeItem = SentryEnvelopeItem.fromEvent(sentryEvent);

      expect(sut.header.eventId, eventId);
      expect(sut.header.sdkVersion, sdkVersion);
      expect(sut.items[0].header.contentType,
          expectedEnvelopeItem.header.contentType);
      expect(sut.items[0].header.type, expectedEnvelopeItem.header.type);
      expect(await sut.items[0].header.length(),
          await expectedEnvelopeItem.header.length());

      final actualItem = await sut.items[0].envelopeItemStream();

      final expectedItem = await expectedEnvelopeItem.envelopeItemStream();

      expect(actualItem, expectedItem);
    });

    // This test passes if no exceptions are thrown, thus no asserts.
    // This is a test for https://github.com/getsentry/sentry-dart/issues/523
    test('serialize with non-serializable class', () async {
      final event = SentryEvent(extra: {'non-ecodable': NonEncodable()});
      final sut = SentryEnvelope.fromEvent(
        event,
        SdkVersion(
          name: 'test',
          version: '1',
        ),
      );

      final _ = sut.envelopeStream().map((e) => e);
    });
  });
}

class NonEncodable {
  final String message = 'Hello World';
}
