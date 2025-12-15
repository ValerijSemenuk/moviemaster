import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/repositories/favorites_repository.dart';
import 'package:moviemaster/domain/usecases/get_favorites.dart';
import '../../mocks/mock_repositories.dart';

void main() {
  late GetFavorites useCase;
  late MockFavoritesRepository mockFavoritesRepository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockFavoritesRepository = MockFavoritesRepository();
    useCase = GetFavorites(mockFavoritesRepository);
  });

  const tUserId = 'user123';
  final tFavorites = [1, 2, 3];

  test('should get favorites from repository', () async {
    when(() => mockFavoritesRepository.getFavorites(any()))
        .thenAnswer((_) async => tFavorites);

    final result = await useCase(tUserId);

    expect(result, tFavorites);
    verify(() => mockFavoritesRepository.getFavorites(tUserId)).called(1);
  });

  test('should propagate exception when repository fails', () async {
    final tException = Exception('Failed to get favorites');
    when(() => mockFavoritesRepository.getFavorites(any()))
        .thenThrow(tException);

    expect(() => useCase(tUserId), throwsA(tException));
    verify(() => mockFavoritesRepository.getFavorites(tUserId)).called(1);
  });
}