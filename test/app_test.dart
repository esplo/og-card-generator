@TestOn('browser')
import 'package:og_card_generator/app_component.dart';
import 'package:og_card_generator/app_component.template.dart' as ng;
import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';

void main() {
  final testBed =
      NgTestBed.forComponent<AppComponent>(ng.AppComponentNgFactory);
  NgTestFixture<AppComponent> fixture;

  setUp(() async {
    fixture = await testBed.create();
  });

  tearDown(disposeAnyRunningTest);

  test('texts', () {
    expect(fixture.text, contains('OG Card Generator'));
    expect(fixture.text, contains('Preview'));
    expect(fixture.text, contains('HTML'));
    expect(fixture.text, contains('CSS'));

    expect(fixture.text, contains('will be shown here'));
    expect(fixture.text, contains('description'));
  });

  test('HTML field', () async {
    final app = AppComponent(); // redundant
    final imageUrl =
        'https://4.bp.blogspot.com/-8enMjG-Dm2A/W6DTGRyxkmI/AAAAAAABO5U/s4YjEAi2wLkuSTjy_UKFrFxe-RQ2Z7XKgCLcBGAs/s800/business_unicorn_company.png';
    final md = MetaData(
      title: 'OuterTitle',
      description: 'OuterDescription',
      imageUrl: Uri.parse(imageUrl),
    );
    final html = app.convertToResult(md);

    await fixture.update((c) => c.result = html);
    expect(
        fixture.text,
        allOf([
          contains('OuterTitle'),
          contains('OuterDescription'),
          contains(imageUrl),
        ]));
  });
}
