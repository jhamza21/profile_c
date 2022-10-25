import 'package:profilecenter/models/qcm_certification.dart';

QcmCertification lastQcmFailed(
    List<QcmCertification> qcmCertifs, String moduleName, String qcmLevel) {
  QcmCertification _qcmCertif = qcmCertifs.lastWhere(
      (element) =>
          element.moduleName == moduleName &&
          element.levelName == qcmLevel &&
          element.status == "failed",
      orElse: () => null);

  var test1 = _qcmCertif;
  return test1;
}
