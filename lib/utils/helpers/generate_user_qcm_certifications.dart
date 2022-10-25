import 'package:profilecenter/models/qcm_certification.dart';

List<QcmCertification> generateUserCertifications(
    List<QcmCertification> _userCertifs) {
  List<QcmCertification> _certifications = [];
  if (_userCertifs == null) return [];
  for (int i = 0; i < _userCertifs.length; i++) {
    double _moyenne = 0;
    String moduleName = _userCertifs[i].moduleName;
    int nbrTestPassed = 0;

    for (int j = i; j < _userCertifs.length; j++) {
      if (_userCertifs[j].moduleName == moduleName &&
          _userCertifs[j].status == "success") {
        nbrTestPassed++;
        if (_userCertifs[j].levelName == "1")
          _moyenne += _userCertifs[j].mark * 0.8;
        if (_userCertifs[j].levelName == "2")
          _moyenne += _userCertifs[j].mark * 1;
        if (_userCertifs[j].levelName == "3")
          _moyenne += _userCertifs[j].mark * 1.2;
      }
    }
    if (nbrTestPassed != 0) {
      QcmCertification _qcmCertif = QcmCertification(
          id: _userCertifs[i].id,
          moduleName: moduleName,
          levelName: _userCertifs[i].levelName,
          status: "success",
          seuil: _userCertifs[i].seuil,
          createdAt: _userCertifs[i].createdAt,
          mark: _moyenne / nbrTestPassed);
      _certifications.add(_qcmCertif);
    }
  }
  return _certifications;
}
