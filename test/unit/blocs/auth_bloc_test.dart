import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/user_entity.dart';
import 'package:moviemaster/domain/repositories/auth_repository.dart';
import 'package:moviemaster/presentation/blocs/auth_bloc/auth_bloc.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  final tUser = UserEntity(
    id: 'user123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
  );

  setUpAll(() {
    registerAllFallbackValues();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('SignInWithGoogle', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when successful',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithGoogle()),
      expect: () => [
        AuthLoading(),
        Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when returns null',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithGoogle()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when fails',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenThrow(Exception('Google sign in failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithGoogle()),
      expect: () => [
        AuthLoading(),
        AuthError('Exception: Google sign in failed'),
      ],
    );
  });

  group('SignInWithEmailAndPassword', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when successful',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        AuthLoading(),
        Authenticated(tUser),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword)).called(1);
      },
    );
  });

  group('RegisterWithEmailAndPassword', () {
    const tEmail = 'new@example.com';
    const tPassword = 'password123';

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when successful',
      build: () {
        when(() => mockAuthRepository.registerWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        AuthLoading(),
        Authenticated(tUser),
      ],
    );
  });

  group('SignOut', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when successful',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(SignOut()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });

  group('CheckAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when user is logged in',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        AuthLoading(),
        Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when no user',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });
}