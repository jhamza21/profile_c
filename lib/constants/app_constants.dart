import 'package:flutter/material.dart';

//backend url
const URL_BACKEND = "http://193.46.198.127/profileCenterBack/public/";

//const URL_BACKEND = "https://profilecenter.elastic-solutions.com/public/api/";
//const URL_BACKEND_PHOTO = "https://profilecenter.elastic-solutions.com/public/";
//Documents types
const IDENTITY_DOC = "identity_doc";
const CV_DOC = "cv_doc";
const PORTFOLIO_DOC = "portfolio_doc";
const OTHERS_DOC = "other_doc";
const COVER_LETTER_DOC = "cover_letter_doc";
const DIPLOMAS_DOC = "diplomas_doc";
const VIDEO_PRESENTATION = "video_doc";
const STATUS_DOC = "statuts_doc";
const KBIS_DOC = "kbis_doc";
const RIB_DOC = "rib_doc";

//colors
const RED_DARK = Color(0xffed5f4c);
const RED_LIGHT = Color(0xffffdcd8);
const RED_BURGUNDY = Color(0xff3c2f40);
const BLUE_DARK = Color(0xff0d1d2c);
const BLUE_DARK_LIGHT = Color(0xff132235);
const BLUE_LIGHT = Color(0xff1a2840);
const BLUE_LIGHT1 = Color(0xff1a3550);
const BLUE_SKY = Color(0xff4c83ee);
const GREY_DARK = Color(0xff797e89);
const GREY_LIGHt = Color(0xff969a9b);
const GREEN_LIGHT = Color(0xff59bc73);
const GREEN_DARK = Color(0xff152f34);
const YELLOW_DARK = Color(0xff2b3430);
const YELLOW_LIGHT = Color(0xffffd703);
const RED = "0xffFF0000";
const BLUE = "0xff0000FF";
const GREEN = "0xff00FF00";
const BROWN = "0xff964B00";
const PURPLE = "0xff800080";
const YELLOW = "0xffFFFF00";

const GOOGLE_MAPS_API_KEY = "AIzaSyDGyCCobvHlYwklHEhVRy00Tga5F-XOvJY";

const DOCS_FILE_EXTENSION = ['jpg', 'png', 'jpeg', 'pdf', 'docx', 'doc'];
const VIDEO_EXTENSION = ['mp4'];

const INTERSHIP_OFFER = "INTERSHIP_OFFER";
const JOB_OFFER = "JOB_OFFER";
const PROJECT_OFFER = "PROJECT_OFFER";
const OFFRE_EXTERNE = "OFFRE_EXTERNE";

const FREELANCE_ROLE = "freelance";
const SALARIEE_ROLE = "salarie";
const STAGIAIRE_ROLE = "stagiaire";
const APPRENTI_ROLE = "apprenti";
const COMPANY_ROLE = "entreprise";

const CALENDAR_PRIVILEGE = "CALENDAR";
const CHAT_PRIVILEGE = "CHAT_CENTER";
const CANDIDAT_NAMES_PRIVILEGE = "CANDIDATS_NAMES";
const COMPARATOR_DATA_PRIVILEGE = "COMPARATOR_DATA";
const POSTULATE_PRIVILEGE = "POSTULATE";
const QCM_PRIVILEGE = "QCM";

const List<String> ROLES_FILTER = [
  "FREELANCE",
  "SALARIE",
  "STAGIAIRE",
  "APPRENTI"
];

const List<String> DISTANCES_FILTER = ["10", "20", "50", "100"];

const List<String> SALARIES_FILTER = ["100", "250", "400", "600", "1000"];

const List<String> EXPERIENCES_FILTER = ["<3", "[3-8]", ">8"];

const List<String> MOBILITIES_FILTER = ["remote", "presentiel", "indifferent"];

const List<String> OFFER_TYPES_FILTER = [
  JOB_OFFER,
  PROJECT_OFFER,
  INTERSHIP_OFFER,
];
const List<String> LANGUAGES_FILTER = [
  "Français",
  "Anglais",
  "Allemand",
  "Espagnol",
  "Italien"
];

const EXPERIENCE_TYPE = "experience";
const MISSION_TYPE = "mission";

//MESSAGE TYPES
const TEXT_MSG = "text_message";
const QCM_REQUEST = "qcm_request";
const QCM_RESPONSE = "qcm_response";
const DOCUMENT_TYPE = "document";
const DOCUMENT_MSG = "qcm_request";
const PROJECT_PROPOSAL = "project_proposal";
const PROJECT_PROPOSAL_RESPONSE = "proposal_response";
const DEVIS_REQUEST = "devis_request";
const DEVIS_RESPONSE = "devis_response";
const SUPPLY_REQUEST = "supply_request";
const STRIPE_SUBSCRIPTION_REQUEST = "stripe_subscription_request";
const PAY_PROPOSAL = "pay_proposal";
const PAY_REQUEST = "pay_request";
const PAY_RESPONSE = "pay_response";
const RAITING_REQUEST = "raiting_request";
const RAITING_RESPONSE = "raiting_response";

final otpInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 15),
  enabledBorder: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  border: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: RED_LIGHT),
  );
}
