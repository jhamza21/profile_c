import 'package:flutter/material.dart';

import 'package:profilecenter/modules/auth/forgot_password/forgot_password.dart';
import 'package:profilecenter/modules/auth/register/signup.dart';
import 'package:profilecenter/modules/chatCenter/chat_screen.dart';
import 'package:profilecenter/modules/chatCenter/devis_details.dart';
import 'package:profilecenter/modules/chatCenter/invoice_details.dart';
import 'package:profilecenter/modules/chatCenter/supply_screen/pay_supply/pay_supply.dart';
import 'package:profilecenter/modules/chatCenter/supply_screen/supply_screen.dart';
import 'package:profilecenter/modules/companyOffers/add_update_offer.dart';
import 'package:profilecenter/modules/companyOffers/company_offers.dart';
import 'package:profilecenter/modules/compareCenter/compare_screen.dart';
import 'package:profilecenter/modules/settings/app_settings.dart';
import 'package:profilecenter/modules/settings/devise_changer.dart';
import 'package:profilecenter/modules/settings/pack_changer_candidat.dart';
import 'package:profilecenter/modules/disponibility/add_update_meeting.dart';
import 'package:profilecenter/modules/disponibility/disponibility_candidat.dart';
import 'package:profilecenter/modules/disponibility/disponibility_company.dart';
import 'package:profilecenter/modules/documents/add_document.dart';
import 'package:profilecenter/modules/documents/add_update_company_data.dart';
import 'package:profilecenter/modules/documents/add_update_legal_mention.dart';
import 'package:profilecenter/modules/documents/files_center_company.dart';
import 'package:profilecenter/modules/experiences/add_update_experience.dart';
import 'package:profilecenter/modules/documents/add_update_cover_letter_doc.dart';
import 'package:profilecenter/modules/documents/add_update_cv_doc.dart';
import 'package:profilecenter/modules/documents/add_update_diplomas_doc.dart';
import 'package:profilecenter/modules/documents/add_update_portfolio_doc.dart';
import 'package:profilecenter/modules/documents/files_center_candidat.dart';
import 'package:profilecenter/modules/auth/login/login.dart';
import 'package:profilecenter/modules/favoriteCandidat/favorite_candidat.dart';
import 'package:profilecenter/modules/financeCenter/finance_company.dart';
import 'package:profilecenter/modules/financeCenter/residency_permi_changer.dart';
import 'package:profilecenter/modules/financeCenter/salary_changer.dart';
import 'package:profilecenter/modules/home/home_root.dart';
import 'package:profilecenter/modules/infoCompany/add_update_company_logo.dart';
import 'package:profilecenter/modules/infoCompany/add_update_company_mobile.dart';
import 'package:profilecenter/modules/infoCompany/add_update_company_name.dart';
import 'package:profilecenter/modules/infoCompany/add_update_rh_name.dart';
import 'package:profilecenter/modules/infoCompany/company_info.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_address.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_password.dart';
import 'package:profilecenter/modules/mission/add_update_old_mission.dart';
import 'package:profilecenter/modules/settings/language_changer.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_birthday.dart';
import 'package:profilecenter/modules/documents/add_update_identity_doc.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_email.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_mobile.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_name.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_photo.dart';
import 'package:profilecenter/modules/certificats/add_update_certificat.dart';
import 'package:profilecenter/modules/infoCandidate/candidate_info.dart';
import 'package:profilecenter/modules/financeCenter/finance_candidat.dart';
import 'package:profilecenter/modules/offers/apply_to_project.dart';
import 'package:profilecenter/modules/profile/company_profile.dart';
import 'package:profilecenter/modules/offers/offer_details.dart';
import 'package:profilecenter/modules/offers/postulate_to_job_intership_offer.dart';
import 'package:profilecenter/modules/profile/profile_pro.dart';
import 'package:profilecenter/modules/profile/candidat_profile.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_center.dart';
import 'package:profilecenter/modules/qcmCenter/qcm_screen.dart';

import 'package:profilecenter/modules/auth/otp_verification/otp_verification.dart';
import 'package:profilecenter/modules/auth/register/terme_condition.dart';
import 'package:profilecenter/modules/settings/pack_changer_company.dart';
import 'package:profilecenter/modules/settings/pay_pack/pay_pack.dart';
import 'package:profilecenter/modules/walk_through/getting_started.dart';
import 'package:profilecenter/modules/support/help_screen.dart';
import 'package:profilecenter/modules/documents/add_List_Devis.dart';
import 'package:profilecenter/modules/documents/add_List_Facture.dart';
import 'package:profilecenter/modules/documents/add_update_kbis.dart';
import 'package:profilecenter/modules/home/candidat_home.dart';
import 'package:profilecenter/modules/home/company_home.dart';
import 'package:profilecenter/modules/infoCandidate/add_update_date.dart';
import 'package:profilecenter/modules/mission/mission_details.dart';
import 'package:profilecenter/modules/splash/splash.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  var routes = <String, WidgetBuilder>{
    AddUpdateExperience.routeName: (ctx) =>
        AddUpdateExperience(settings.arguments),
    AddUpdateCertificat.routeName: (ctx) =>
        AddUpdateCertificat(settings.arguments),
    AddUpdateOldMission.routeName: (ctx) =>
        AddUpdateOldMission(settings.arguments),
    AddUpdateAddress.routeName: (ctx) => AddUpdateAddress(settings.arguments),
    QcmCenter.routeName: (ctx) => QcmCenter(settings.arguments),
    QcmScreen.routeName: (ctx) => QcmScreen(settings.arguments),
    CandidatProfile.routeName: (ctx) => CandidatProfile(settings.arguments),
    AddUpdateMeeting.routeName: (ctx) => AddUpdateMeeting(settings.arguments),
    AddUpdateOffer.routeName: (ctx) => AddUpdateOffer(settings.arguments),
    OfferDetails.routeName: (ctx) => OfferDetails(settings.arguments),
    PostulateToJobIntershipOffer.routeName: (ctx) =>
        PostulateToJobIntershipOffer(settings.arguments),
    CompanyeProfile.routeName: (ctx) => CompanyeProfile(settings.arguments),
    ChatScreen.routeName: (ctx) => ChatScreen(settings.arguments),
    CompareScreen.routeName: (ctx) => CompareScreen(settings.arguments),
    AddDocument.routeName: (ctx) => AddDocument(settings.arguments),
    ApplyToProject.routeName: (ctx) => ApplyToProject(settings.arguments),
    DevisDetails.routeName: (ctx) => DevisDetails(settings.arguments),
    SupplyScreen.routeName: (ctx) => SupplyScreen(settings.arguments),
    InvoiceDetails.routeName: (ctx) => InvoiceDetails(settings.arguments),
    MissionDetails.routeName: (ctx) => MissionDetails(settings.arguments),
    PayPack.routeName: (ctx) => PayPack(arguments: settings.arguments),
    PaySupply.routeName: (ctx) => PaySupply(arguments: settings.arguments),
    Login.routeName: (ctx) => Login(),
    SignUp.routeName: (ctx) => SignUp(),
    ForgotPassword.routeName: (ctx) => ForgotPassword(),
    OtpScreen.routeName: (ctx) => OtpScreen(),
    HelpScreen.routeName: (ctx) => HelpScreen(),
    LanguageChanger.routeName: (ctx) => LanguageChanger(),
    HomeRoot.routeName: (ctx) => HomeRoot(),
    CompanyHome.routeName: (ctx) => CompanyHome(),
    GettingStarted.routeName: (ctx) => GettingStarted(),
    CandidatHome.routeName: (ctx) => CandidatHome(),
    CandidateInfo.routeName: (ctx) => CandidateInfo(),
    CompanyInfo.routeName: (ctx) => CompanyInfo(),
    TermeCondition.routeName: (ctx) => TermeCondition(),
    AddUpdateName.routeName: (ctx) => AddUpdateName(),
    AddListFacture.routeName: (ctx) => AddListFacture(),
    AddListDevis.routeName: (ctx) => AddListDevis(),
    SplashScreen.routeName: (ctx) => SplashScreen(),
    AddUpdateCompanyLogo.routeName: (ctx) => AddUpdateCompanyLogo(),
    AddUpdateCompanyMobile.routeName: (ctx) => AddUpdateCompanyMobile(),
    AddUpdateCompanyName.routeName: (ctx) => AddUpdateCompanyName(),
    AddUpdateRhName.routeName: (ctx) => AddUpdateRhName(),
    AddUpdateEmail.routeName: (ctx) => AddUpdateEmail(),
    AddUpdatePassword.routeName: (ctx) => AddUpdatePassword(),
    AddUpdateMobile.routeName: (ctx) => AddUpdateMobile(),
    AddUpdateBirthday.routeName: (ctx) => AddUpdateBirthday(),
    AddUpdateDate.routeName: (ctx) => AddUpdateDate(),
    FavoriteCandidat.routeName: (ctx) => FavoriteCandidat(),
    AddUpdatePhoto.routeName: (ctx) => AddUpdatePhoto(),
    ProfilePro.routeName: (ctx) => ProfilePro(),
    FinanceCandidat.routeName: (ctx) => FinanceCandidat(),
    FinanceCompany.routeName: (ctx) => FinanceCompany(),
    FilesCenterCompany.routeName: (ctx) => FilesCenterCompany(),
    FilesCenterCandidat.routeName: (ctx) => FilesCenterCandidat(),
    AddUpdateIdentityDoc.routeName: (ctx) => AddUpdateIdentityDoc(),
    AddUpdatePortfolioDoc.routeName: (ctx) => AddUpdatePortfolioDoc(),
    AddUpdateKbisDoc.routeName: (ctx) => AddUpdateKbisDoc(),
    AddUpdateCompanyData.routeName: (ctx) => AddUpdateCompanyData(),
    AddUpdateCvDoc.routeName: (ctx) => AddUpdateCvDoc(),
    AddUpdateCoverLetterDoc.routeName: (ctx) => AddUpdateCoverLetterDoc(),
    AddUpdateDiplomasDoc.routeName: (ctx) => AddUpdateDiplomasDoc(),
    AddUpdateLegalMention.routeName: (ctx) => AddUpdateLegalMention(),
    AppSettings.routeName: (ctx) => AppSettings(),
    DisponibilityCandidat.routeName: (ctx) => DisponibilityCandidat(),
    DisponibilityCompany.routeName: (ctx) => DisponibilityCompany(),
    CompanyOffers.routeName: (ctx) => CompanyOffers(),
    SalaryChanger.routeName: (ctx) => SalaryChanger(),
    DeviseChanger.routeName: (ctx) => DeviseChanger(),
    PackChangerCandidat.routeName: (ctx) => PackChangerCandidat(),
    PackChangerCompany.routeName: (ctx) => PackChangerCompany(),
    ResidencyPermitChanger.routeName: (ctx) => ResidencyPermitChanger(),
  };
  WidgetBuilder builder = routes[settings.name];
  return MaterialPageRoute(builder: (ctx) => builder(ctx));
}
