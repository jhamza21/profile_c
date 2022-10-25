import 'dart:convert';

import 'package:client_information/client_information.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/modules/home/candidat_home.dart';
import 'package:profilecenter/modules/home/company_home.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/core/services/auth_service.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  static String routeName = "/otp";

  const OtpScreen({Key key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;
  String clientInfo;
  String value;
  String mycode;

  void initState() {
    super.initState();
    _sendOtpemail();
    _getClientInformation();
  }

  Future<void> _getClientInformation() async {
    ClientInformation infoId;
    try {
      infoId = await ClientInformation.fetch();
    } catch (e) {}
    if (!mounted) return;

    setState(() {
      clientInfo = infoId.deviceId;
    });
  }

  _sendOtpemail() async {
    try {
      await AuthService().sendOtpEmail();
    } catch (e) {}
  }

  void resendCode(context) async {
    showBottomModal(
        context,
        getTranslate(context, "ACCOUNT_VERIFICATION"),
        getTranslate(context, "VERIFY_YOUR_ACCOUNT"),
        "OK",
        () {
          Navigator.of(context).pop();
        },
        getTranslate(context, "RESEND_LINK"),
        () async {
          _sendOtpemail();
          Navigator.of(context).pop();
        });
  }

  Widget buildContinueBtn() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return TextButton.icon(
      icon: _isLoading ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'GET_START'),
        style: TextStyle(fontSize: 20),
      ),
      onPressed: _isLoading || mycode == null || mycode.length != 6
          ? null
          : () async {
              try {
                setState(() {
                  _isLoading = true;
                });
                var res = await AuthService().validateOtp(mycode);
                if (res.statusCode == 401) return sessionExpired(context);
                if (res.statusCode != 200) throw "ERROR_SERVER";
                final jsonData = json.decode(res.body);
                if (mycode == jsonData["code"]) {
                  if (userProvider.user.role == COMPANY_ROLE) {
                    Navigator.of(context).pushNamed(CompanyHome.routeName);
                  } else {
                    Navigator.of(context).pushNamed(CandidatHome.routeName);
                  }
                  SecureStorageService.saveClientInfo(clientInfo);
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                  showSnackbar(context,
                      "Votre code est incorrecte, verifier votre email");
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
              }
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: RED_LIGHT,
        backgroundColor: RED_DARK,
        minimumSize: Size(200, 45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(getTranslate(context, 'CODE_VERIFICATION'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: RED_DARK,
                      fontSize: 22,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                getTranslate(context, 'SUB_MSG'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 120),
              SizedBox(
                width: 300,
                height: 200,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    mycode = value.trim();
                    setState(() {});
                  },
                  pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      inactiveColor: Colors.grey,
                      activeColor: RED_DARK,
                      selectedColor: RED_DARK),
                ),
              ),
              buildContinueBtn(),
              SizedBox(height: 20),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent)),
                  onPressed: () async {
                    resendCode(context);
                  },
                  child: Text(
                    getTranslate(context, 'RESEND_OTP'),
                    style: TextStyle(decoration: TextDecoration.underline),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
