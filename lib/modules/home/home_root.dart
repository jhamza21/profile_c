import 'package:client_information/client_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profilecenter/modules/auth/otp_verification/otp_verification.dart';
import 'package:profilecenter/modules/walk_through/getting_started.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/modules/home/candidat_home.dart';
import 'package:profilecenter/modules/home/company_home.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/widgets/waiting_screen.dart';
import 'package:provider/provider.dart';
import 'package:profilecenter/constants/app_constants.dart';

class HomeRoot extends StatefulWidget {
  static const routeName = '/homeRoot';
  @override
  State<StatefulWidget> createState() => new _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> {
  String clientInfo;
  String infoId2, email1;

  @override
  void initState() {
    super.initState();
    getConnectedUser();
    _getClientInformation();
    readInfo();
  }

  void getConnectedUser() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.checkLoggedInUser();
  }

  Future<void> _getClientInformation() async {
    ClientInformation infoId;
    try {
      infoId = await ClientInformation.fetch();
    } on PlatformException {}
    if (!mounted) return;

    setState(() {
      clientInfo = infoId.deviceId;
    });
  }

  void readInfo() async {
    String infoId1 = await SecureStorageService.readClientInfo();
    String email = await SecureStorageService.readClientEmail();
    setState(() {
      infoId2 = infoId1;
      email1 = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    if (userProvider.isLoading)
      return WaitingScreen();
    else if (userProvider.isLoggedIn) {
      if (userProvider.user.role == COMPANY_ROLE) if (infoId2 == null) {
        return OtpScreen();
      } else {
        return CompanyHome();
      }
      else if (infoId2 == null) {
        return OtpScreen();
      } else {
        return CandidatHome();
      }
    } else
      return GettingStarted();
  }
}
