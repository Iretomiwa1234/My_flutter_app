import 'package:my_app/services/auth/auth_provider.dart';
import 'package:my_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('MockAuthProvider', () {
    late MockAuthProvider provider;

    setUp(() {
      provider = MockAuthProvider();
    });

    test('should not be initialized initially', () {
      expect(provider.isInitialized, false);
    });

    test('should initialize after calling initialize()', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null before logging in', () {
      expect(provider.currentUser, isNull);
    });

    test('User should be null after initialization', () async {
      await provider.initialize();
      expect(provider.currentUser, isNull);
    });

    test(
      'Should be able to initialize in less than 3 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 3)),
    );

    test('Create user should delegate to logIn - bad email', () async {
      await provider.initialize();
      final badEmailUser = provider.createUser(
        email: 'footies.com',
        password: 'password123',
      );
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundException>()));
    });

    test('Create user should delegate to logIn - bad password', () async {
      await provider.initialize();
      final badPasswordUser = provider.createUser(
        email: 'someone@bar.com',
        password: 'wrongpassword',
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordException>()),
      );
    });

    test(
      'sendEmailVerification should update isEmailVerified to true',
      () async {
        await provider.initialize();
        await provider.createUser(email: 'ade', password: 'password123');
        await provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      },
    );

    test('logOut should clear the current user', () async {
      await provider.initialize();
      await provider.createUser(email: 'ade', password: 'password123');
      expect(provider.currentUser, isNotNull);
      await provider.logOut();
      expect(provider.currentUser, isNull);
    });

    test('throws exception when logOut is called before initialize', () async {
      final uninitializedProvider = MockAuthProvider();
      expect(
        () => uninitializedProvider.logOut(),
        throwsA(isA<NotInitializedException>()),
      );
    });

    test(
      'throws exception when sendEmailVerification is called without login',
      () async {
        await provider.initialize();
        expect(
          () => provider.sendEmailVerification(),
          throwsA(isA<UserNotFoundException>()),
        );
      },
    );

    test('Create user should return a valid AuthUser', () async {
      await provider.initialize();
      final user = await provider.createUser(
        email: 'ade',
        password: 'password123',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get email verification', () async {
      await provider.initialize();
      await provider.createUser(email: 'ade', password: 'password123');
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and login again', () async {
      await provider.initialize();
      await provider.createUser(email: 'ade', password: 'password123');
      await provider.logOut();
      await provider.logIn(email: 'ade', password: 'password123');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class UserNotFoundException implements Exception {}

class WrongPasswordException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      await Future.delayed(const Duration(seconds: 2));
      throw NotInitializedException();
    }
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'footies.com') throw UserNotFoundException();
    if (password == 'wrongpassword') throw WrongPasswordException();
    final user = AuthUser(email: email, isEmailVerified: false);
    _user = user;
    return user;
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();
    final newUser = AuthUser(email: _user!.email, isEmailVerified: true);
    _user = newUser;
  }
}
