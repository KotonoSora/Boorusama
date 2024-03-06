// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

void main() {
  final simpleTestData = {'a', 'b', 'c'}.toTagFilterData();

  group('single', () {
    group('no operator', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'a'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'd'),
          false,
        );
      });
    });

    group('NOT', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, '-d'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, '-a'),
          false,
        );
      });
    });

    group('OR', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, '~a'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, '~d'),
          false,
        );
      });
    });

    group('Metatags', () {
      group('Rating', () {
        group('General', () {
          test('positive', () {
            expect(
              checkIfTagsContainsTagExpression(
                TagFilterData(
                  tags: {'a', 'b', 'c'},
                  rating: Rating.general,
                  score: 0,
                ),
                'rating:general',
              ),
              true,
            );
          });

          test('negative', () {
            expect(
              checkIfTagsContainsTagExpression(
                TagFilterData(
                  tags: {'a', 'b', 'c'},
                  rating: Rating.general,
                  score: 0,
                ),
                'rating:explicit',
              ),
              false,
            );
          });
        });
      });

      group('Score', () {
        test('positive', () {
          expect(
            checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: -10,
              ),
              'score:<-4',
            ),
            true,
          );
        });

        test('negative', () {
          expect(
            checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: 0,
              ),
              'score:<-4',
            ),
            false,
          );
        });
      });
    });
  });

  group('multiple', () {
    group('AND', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'a b'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'a d'),
          false,
        );
      });
    });

    group('OR', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, '~a ~b'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, '~d ~e'),
          false,
        );
      });
    });

    // NOT group
    group('NOT', () {
      test('positive 1', () {
        expect(
          checkIfTagsContainsTagExpression(
              {'a', 'b', 'q', 'w'}.toTagFilterData(), 'a b -c -d'),
          true,
        );
      });

      test('negative 1', () {
        expect(
          checkIfTagsContainsTagExpression(
              {'a', 'b', 'c', 'd'}.toTagFilterData(), 'a b -c -d'),
          false,
        );
      });

      test('negative 2', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'a b -c -d'),
          false,
        );
      });

      test('negative 3', () {
        expect(
          checkIfTagsContainsTagExpression(
              {'a', 'b', 'd'}.toTagFilterData(), 'a b -c -d'),
          false,
        );
      });

      test('negative 4', () {
        expect(
          checkIfTagsContainsTagExpression(
              {'q', 'w', 'e', 'r'}.toTagFilterData(), 'a b -c -d'),
          false,
        );
      });
    });

    group('AND + OR', () {
      test('positive 1', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'a ~b ~d'),
          true,
        );
      });

      test('positive 2 ', () {
        expect(
          checkIfTagsContainsTagExpression(
              {'a', 'b', 'd'}.toTagFilterData(), 'a ~b ~d'),
          true,
        );
      });

      test('negative 1 (AND exists, OR not exists)', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'a ~d ~e'),
          false,
        );
      });

      test('negative 2 (AND not exists, OR exists)', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'd ~a ~b'),
          false,
        );
      });

      test('negative 3 (AND and OR not exists)', () {
        expect(
          checkIfTagsContainsTagExpression(simpleTestData, 'd ~e'),
          false,
        );
      });
    });

    group('AND + Metatags', () {
      test('positive 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
              ),
              'a rating:explicit'),
          true,
        );
      });

      test('positive 2 (score)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: -10,
              ),
              'a score:<-5'),
          true,
        );
      });

      test('positive 3 (downvotes)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: -10,
                downvotes: 10,
              ),
              'a downvotes:>5'),
          true,
        );
      });

      test('negative 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
              ),
              'a rating:general'),
          false,
        );
      });

      test('negative 2 (score)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: -1,
              ),
              'a score:<-5'),
          false,
        );
      });

      test('negative 3 (downvotes)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: -10,
                downvotes: 10,
              ),
              'a downvotes:>15'),
          false,
        );
      });

      test('negative 4 (downvotes null)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: -10,
                downvotes: null,
              ),
              'a downvotes:<5'),
          false,
        );
      });

      test('positive (uploaderid)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
                uploaderId: 123,
              ),
              'a uploaderid:123'),
          true,
        );
      });

      test('negative (uploaderid)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
                uploaderId: 123,
              ),
              'a uploaderid:321'),
          false,
        );
      });

      test('positive (source exact match)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
                source: 'https://example.com',
              ),
              'a source:https://example.com'),
          true,
        );
      });

      test('negative (source exact match)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
                source: 'https://example.com',
              ),
              'd source:https://example.com'),
          false,
        );
      });

      test('positive (source start match)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
                source: 'https://example.com/abc',
              ),
              'a source:https://example.com*'),
          true,
        );
      });

      test('positive (source end match)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
                source: 'https://example.com/abc',
              ),
              'a source:*example.com/abc'),
          true,
        );
      });

      test('positive (source middle match)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.explicit,
                score: 0,
                source: 'https://example.com/abc',
              ),
              'a source:*example.com*'),
          true,
        );
      });
    });

    group('NOT + Metatags', () {
      test('positive 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: {'a', 'b', 'c'}, rating: Rating.explicit, score: 0),
              'a -rating:general'),
          true,
        );
      });

      test('positive 2 (score + rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: {'a', 'b', 'c'}, rating: Rating.general, score: -10),
              'a score:<-5 -rating:explicit'),
          true,
        );
      });

      test('negative 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: {'a', 'b', 'c'}, rating: Rating.general, score: 0),
              'a -rating:general'),
          false,
        );
      });

      test('negative 2 (score + rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: {'a', 'b', 'c'}, rating: Rating.explicit, score: -100),
              'a score:<-5 -rating:explicit'),
          false,
        );
      });
    });
  });

  group('autocomplete filter', () {
    test('filter matched', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(const {'value': 'a', 'label': 'a'}),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a'},
        shouldFilter: true,
      );

      expect(result.length, 1);
      expect(result.first.value, 'b');
    });

    test('filter matched full tag', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(const {'value': 'a_b', 'label': 'a_b'}),
          AutocompleteData.fromJson(
              const {'value': 'xyz', 'label': 'xyz', 'antecedent': 'a_b'}),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a_b'},
        shouldFilter: true,
      );

      expect(result.length, 1);
      expect(result.first.value, 'b');
    });

    test('word-based filter', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(const {'value': 'ab', 'label': 'ab'}),
          AutocompleteData.fromJson(const {'value': 'a_b', 'label': 'a_b'}),
          AutocompleteData.fromJson(const {'value': 'xyz_a', 'label': 'xyz_a'}),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a'},
        shouldFilter: true,
      );

      expect(result.length, 1);
      expect(result.last.value, 'b');
    });

    test('alias filter', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(
              const {'value': 'foo', 'label': 'foo', 'antecedent': 'a_b'}),
          AutocompleteData.fromJson(
              const {'value': 'foo', 'label': 'foo', 'antecedent': 'b_(a)'}),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a'},
        shouldFilter: true,
      );

      expect(result.length, 1);
      expect(result.first.value, 'b');
    });
  });
}
