import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triftly/core/bloc/cloud_sync/cloud_sync_bloc.dart';
import 'package:triftly/core/repositories/hive_trip_repository.dart';
import 'package:triftly/core/services/user_session.dart';
import 'package:triftly/core/sync/cloud_sync_reporter.dart';

class _MockUserSession extends Mock implements UserSession {}

class _MockHiveTripRepository extends Mock implements HiveTripRepository {}

void main() {
  late CloudSyncReporterBridge reporter;
  late _MockUserSession session;
  late _MockHiveTripRepository repository;

  setUp(() {
    reporter = CloudSyncReporterBridge();
    session = _MockUserSession();
    repository = _MockHiveTripRepository();
  });

  CloudSyncBloc buildBloc() => CloudSyncBloc(
        userSession: session,
        syncReporter: reporter,
        tripRepository: repository,
      );

  group('CloudSyncBloc', () {
    test('initial state is idle', () {
      final bloc = buildBloc();
      expect(bloc.state.isSyncing, isFalse);
      expect(bloc.state.hasError, isFalse);
      bloc.close();
    });

    blocTest<CloudSyncBloc, CloudSyncState>(
      'CloudSyncStarted sets syncing',
      build: buildBloc,
      act: (bloc) => bloc.add(const CloudSyncStarted()),
      expect: () => [
        isA<CloudSyncState>().having((s) => s.isSyncing, 'isSyncing', isTrue),
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'CloudSyncSucceeded clears error and records success time',
      build: buildBloc,
      seed: () => CloudSyncState(lastError: 'offline'),
      act: (bloc) => bloc.add(const CloudSyncSucceeded()),
      expect: () => [
        isA<CloudSyncState>()
            .having((s) => s.isSyncing, 'isSyncing', isFalse)
            .having((s) => s.hasError, 'hasError', isFalse)
            .having((s) => s.lastSuccessAt, 'lastSuccessAt', isNotNull),
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'CloudSyncFailed stores message without Exception prefix',
      build: buildBloc,
      act: (bloc) => bloc.add(CloudSyncFailed(Exception('timeout'))),
      expect: () => [
        isA<CloudSyncState>()
            .having((s) => s.isSyncing, 'isSyncing', isFalse)
            .having((s) => s.lastError, 'lastError', 'timeout'),
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'CloudSyncPushFailed keeps last success time',
      build: buildBloc,
      seed: () => CloudSyncState(lastSuccessAt: DateTime(2026, 1, 1)),
      act: (bloc) => bloc.add(CloudSyncPushFailed(Exception('push failed'))),
      expect: () => [
        isA<CloudSyncState>()
            .having((s) => s.hasError, 'hasError', isTrue)
            .having((s) => s.lastSuccessAt, 'lastSuccessAt', DateTime(2026, 1, 1)),
      ],
    );

    blocTest<CloudSyncBloc, CloudSyncState>(
      'lastSuccessLabel formats recent sync',
      build: buildBloc,
      act: (bloc) => bloc.add(const CloudSyncSucceeded()),
      verify: (bloc) => expect(bloc.state.lastSuccessLabel, 'Synced just now'),
    );

    test('reporter bridge dispatches events to bloc', () async {
      final bloc = buildBloc();
      final states = <CloudSyncState>[];
      final sub = bloc.stream.listen(states.add);

      reporter.begin();
      reporter.succeed();
      await Future<void>.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states.first.isSyncing, isTrue);
      expect(states.last.hasError, isFalse);
      expect(states.last.lastSuccessAt, isNotNull);

      await sub.cancel();
      await bloc.close();
    });
  });
}
