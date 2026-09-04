import 'package:flutter_test/flutter_test.dart';
import 'package:hyaup/core/utils/app_preferences.dart';
import 'package:hyaup/core/utils/currency_formatter.dart';
import 'package:hyaup/data/models/filter_model.dart';
import 'package:hyaup/data/models/job_model.dart';
import 'package:hyaup/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HyaUp Core Logic & Models Test Suite', () {
    test('JobModel parses native employer listing correctly', () {
      final json = {
        'id': 'native-1',
        'title': 'Senior Flutter Engineer',
        'company': 'Paveway Academy',
        'location': 'Douala, Cameroon',
        'source_type': 'native',
        'min_salary': 500000,
        'max_salary': 800000,
        'currency': 'XAF',
        'benefits': {
          'paid_pto': true,
          'health_coverage': true,
          'remote_mode': 'hybrid',
        },
        'required_skills': ['Flutter', 'Dart', 'Firebase'],
        'compatibility_score': 0.92,
      };

      final job = JobModel.fromJson(json);

      expect(job.id, 'native-1');
      expect(job.isNative, true);
      expect(job.isExternal, false);
      expect(job.salaryMin, 500000);
      expect(job.salaryMax, 800000);
      expect(job.hasPaidPto, true);
      expect(job.hasHealthCoverage, true);
      expect(job.remoteMode, 'hybrid');
      expect(job.matchPercentage, 92);
      expect(job.requiredSkills.length, 3);
    });

    test('JobModel parses external scraped listing correctly', () {
      final json = {
        'id': 'ext-1',
        'title': 'Program Director',
        'organization': 'CHAI',
        'city': 'Yaoundé',
        'url': 'https://unjobs.org/vacancies/12345',
        'source_type': 'external',
      };

      final job = JobModel.fromJson(json);

      expect(job.isNative, false);
      expect(job.isExternal, true);
      expect(job.company, 'CHAI');
      expect(job.location, 'Yaoundé');
      expect(job.externalApplyUrl, 'https://unjobs.org/vacancies/12345');
    });

    test('CurrencyFormatter formats FCFA salary ranges accurately', () {
      final formatted = CurrencyFormatter.formatSalaryRange(
        min: 500000,
        max: 850000,
        currency: "XAF",
      );

      expect(formatted, "500,000 - 850,000 FCFA / month");

      final singleAmount = CurrencyFormatter.formatSalaryRange(
        min: 600000,
        max: 600000,
        currency: "XAF",
      );
      expect(singleAmount, "600,000 FCFA / month");

      final undisclosed = CurrencyFormatter.formatSalaryRange();
      expect(undisclosed, "Salary Undisclosed");
    });

    test('FilterModel correctly computes active filters and query params', () {
      final emptyFilter = const FilterModel();
      expect(emptyFilter.isEmpty, true);
      expect(emptyFilter.activeFilterCount, 0);

      final activeFilter = const FilterModel(
        minSalary: 500000,
        hasPaidPto: true,
        remoteMode: 'remote',
      );

      expect(activeFilter.isEmpty, false);
      expect(activeFilter.activeFilterCount, 3);

      final queryParams = activeFilter.toQueryParams();
      expect(queryParams['min_salary'], 500000);
      expect(queryParams['paid_pto'], true);
      expect(queryParams['remote_mode'], 'remote');
    });

    test('AppPreferences correctly handles role and intro persistence', () async {
      SharedPreferences.setMockInitialValues({});

      expect(await AppPreferences.hasSeenIntro(), false);
      expect(await AppPreferences.getUserRole(), null);
      expect(await AppPreferences.isOnboarded(), false);

      await AppPreferences.setHasSeenIntro(true);
      await AppPreferences.setUserRole('employer');
      await AppPreferences.setOnboarded(true);

      expect(await AppPreferences.hasSeenIntro(), true);
      expect(await AppPreferences.getUserRole(), 'employer');
      expect(await AppPreferences.isOnboarded(), true);
    });

    test('UserRepository saves and caches onboarding profiles accurately', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = UserRepository();

      final profile = await repo.saveOnboardingProfile(
        uid: 'user-123',
        email: 'recruiter@mtn.cm',
        role: 'employer',
        onboardingData: {
          'company_name': 'MTN Cameroon',
          'city': 'Douala',
        },
      );

      expect(profile['role'], 'employer');
      expect(profile['company_name'], 'MTN Cameroon');
      expect(profile['city'], 'Douala');
      expect(await AppPreferences.getUserRole(), 'employer');
      expect(await AppPreferences.isOnboarded(), true);
    });
  });
}
