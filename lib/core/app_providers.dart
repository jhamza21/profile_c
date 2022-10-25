import 'package:profilecenter/providers/providers.dart';
import 'package:provider/provider.dart';

onGenerateProviders() {
  return [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => ExperienceProvider()),
    ChangeNotifierProvider(create: (_) => CertificatProvider()),
    ChangeNotifierProvider(create: (_) => MissionProvider()),
    ChangeNotifierProvider(create: (_) => UserSkillsProvider()),
    ChangeNotifierProvider(create: (_) => JobOffersProvider()),
    ChangeNotifierProvider(create: (_) => IntershipOffersProvider()),
    ChangeNotifierProvider(create: (_) => ProjectOffersProvider()),
    ChangeNotifierProvider(create: (_) => MeetingProvider()),
    ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    ChangeNotifierProvider(create: (_) => CompareProvider()),
    ChangeNotifierProvider(create: (_) => CandidatSuggestionsProvider()),
    ChangeNotifierProvider(create: (_) => QcmCertificationProvider()),
    ChangeNotifierProvider(create: (_) => PlatformLanguagesProvider()),
    ChangeNotifierProvider(create: (_) => PlatformSkillsProvider()),
    ChangeNotifierProvider(create: (_) => PlatformToolsProvider()),
    ChangeNotifierProvider(create: (_) => VideoPresentationProvider()),
    ChangeNotifierProvider(create: (_) => CompanyDataProvider()),
    ChangeNotifierProvider(create: (_) => CoverLetterProvider()),
    ChangeNotifierProvider(create: (_) => CvProvider()),
    ChangeNotifierProvider(create: (_) => DiplomasProvider()),
    ChangeNotifierProvider(create: (_) => IdentityDocProvider()),
    // ChangeNotifierProvider(create: (_) => InfoBankProvider()),
    ChangeNotifierProvider(create: (_) => MentionLegalDataProvider()),
    ChangeNotifierProvider(create: (_) => PortfolioProvider()),
    ChangeNotifierProvider(create: (_) => KbisProvider()),
    ChangeNotifierProvider(create: (_) => ChatRoomProvider()),
    ChangeNotifierProvider(create: (_) => MessageProvider()),
    ChangeNotifierProvider(create: (_) => DeviseProvider()),
    ChangeNotifierProvider(create: (_) => DescriptionProvider()),
    ChangeNotifierProvider(create: (_) => SupportedCountriesProvider()),
    ChangeNotifierProvider(create: (_) => StatisticProvider()),
  ];
}
