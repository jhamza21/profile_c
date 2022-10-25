import 'package:profilecenter/models/qcm_certification.dart';

QcmCertification lastQcmSuccess(
    List<QcmCertification> qcmCertifs, String moduleName, String qcmLevel) {
  QcmCertification _qcmCertif = qcmCertifs.lastWhere(
      (element) =>
          element.moduleName == moduleName &&
          element.levelName == qcmLevel &&
          element.status == "success",
      orElse: () => null);
  var test = _qcmCertif;
  return test;
}
