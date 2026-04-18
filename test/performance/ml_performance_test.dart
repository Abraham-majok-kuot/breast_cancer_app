import 'package:flutter_test/flutter_test.dart';
import 'package:breast_cancer_app/views/ml_service.dart';

void main() {
  setUp(() => MLService.dispose());

  group('MLService – inference performance', () {
    test('single predict() completes in under 200ms', () async {
      final stopwatch = Stopwatch()..start();
      await MLService.predict(
        age: 45, bmi: 27,
        familyHistory: true, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Good',
      );
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(200),
          reason: 'Inference (or fallback) must complete in < 200 ms');
    });

    test('100 consecutive predict() calls complete in under 2000ms', () async {
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        await MLService.predict(
          age: 20.0 + i * 0.6, bmi: 18.0 + i * 0.27,
          familyHistory: i.isEven, hadBiopsy: i % 3 == 0,
          breastfeeding: i.isOdd, hormonalContraceptives: i % 4 == 0,
          smoking: ['No', 'Occasionally', 'Yes'][i % 3],
          alcohol: ['None', 'Light', 'Moderate', 'Heavy'][i % 4],
          exercise: ['None', 'Light', 'Moderate', 'Active'][i % 4],
          diet: ['Poor', 'Average', 'Good', 'Excellent'][i % 4],
        );
      }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: '100 predictions must complete in < 2 seconds');
    });

    test('average predict() latency under 10ms for 50 calls', () async {
      const calls = 50;
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < calls; i++) {
        await MLService.predict(
          age: 35, bmi: 22,
          familyHistory: false, hadBiopsy: false,
          breastfeeding: true, hormonalContraceptives: false,
          smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Good',
        );
      }
      stopwatch.stop();
      final avgMs = stopwatch.elapsedMilliseconds / calls;
      expect(avgMs, lessThan(10),
          reason: 'Average per-call latency must be < 10 ms');
    });

    test('predict() after dispose() does not degrade performance', () async {
      // Warm up
      await MLService.predict(
        age: 35, bmi: 22,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Good',
      );

      MLService.dispose();

      final stopwatch = Stopwatch()..start();
      await MLService.predict(
        age: 35, bmi: 22,
        familyHistory: false, hadBiopsy: false,
        breastfeeding: true, hormonalContraceptives: false,
        smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Good',
      );
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'First call after dispose must still complete in < 500 ms');
    });

    test('concurrent predict() calls all complete without error', () async {
      final futures = List.generate(
        20,
        (i) => MLService.predict(
          age: 25.0 + i, bmi: 20.0 + i * 0.5,
          familyHistory: i.isEven, hadBiopsy: false,
          breastfeeding: true, hormonalContraceptives: i.isOdd,
          smoking: 'No', alcohol: 'None', exercise: 'Active', diet: 'Good',
        ),
      );

      final results = await Future.wait(futures);
      expect(results.length, 20);
      for (final r in results) {
        expect(r, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('MLService – throughput benchmarks', () {
    test('processes 1000 predictions in under 10 seconds', () async {
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        await MLService.predict(
          age: 18 + (i % 62).toDouble(),
          bmi: 15 + (i % 30).toDouble(),
          familyHistory: i.isEven,
          hadBiopsy: i % 5 == 0,
          breastfeeding: i % 2 == 0,
          hormonalContraceptives: i % 3 == 0,
          smoking: ['No', 'Occasionally', 'Yes'][i % 3],
          alcohol: ['None', 'Light', 'Moderate', 'Heavy'][i % 4],
          exercise: ['None', 'Light', 'Moderate', 'Active'][i % 4],
          diet: ['Poor', 'Average', 'Good', 'Excellent'][i % 4],
        );
      }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(10000),
          reason: '1000 predictions must complete in < 10 seconds');
    });
  });
}
