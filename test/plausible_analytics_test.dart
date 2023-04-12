import 'package:flutter_test/flutter_test.dart';
import 'package:plausible_analytics/plausible_analytics.dart';

const String serverUrl = "https://analytics.bostrot.com";
const String domain = "example.com";
const String name = "pageview";
const String url = "app://localhost/test";
const String referrer = "app://localhost/referrer";
const int screenWidth = 384;

void main() {
  test('make plausible event call with pageview', () async {
    final plausible = Plausible(serverUrl, domain, screenWidth: screenWidth);
    expect(plausible.serverUrl, serverUrl);
    expect(plausible.domain, domain);
    expect(plausible.screenWidth, screenWidth);

    final event = plausible.event();
    expect(await event, 202);
  });

  test('make plausible event call with custom event', () async {
    final plausible = Plausible(serverUrl, domain, screenWidth: screenWidth);
    expect(plausible.serverUrl, serverUrl);
    expect(plausible.domain, domain);
    expect(plausible.screenWidth, screenWidth);

    final event = plausible.event(
        name: 'conversion', page: 'homescreen', referrer: 'referrerPage');
    expect(await event, 202);
  });

  test('check disabled call', () async {
    final plausible = Plausible(serverUrl, domain, screenWidth: screenWidth);
    plausible.enabled = false;
    expect(plausible.serverUrl, serverUrl);
    expect(plausible.domain, domain);
    expect(plausible.screenWidth, screenWidth);

    final event = plausible.event(
        name: 'conversion', page: 'homescreen', referrer: 'referrerPage');
    expect(await event, 0);
  });

  test('check failed http request', () async {
    final plausible =
        Plausible("somewrongurl.asd21", domain, screenWidth: screenWidth);
    expect(plausible.serverUrl, "somewrongurl.asd21");
    expect(plausible.domain, domain);
    expect(plausible.screenWidth, screenWidth);

    final event = plausible.event(
        name: 'conversion', page: 'homescreen', referrer: 'referrerPage');
    expect(await event, 1);
  });
}
