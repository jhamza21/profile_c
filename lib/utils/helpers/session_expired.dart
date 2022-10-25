import 'package:flutter/material.dart';
import 'package:profilecenter/modules/home/home_root.dart';
import 'package:profilecenter/providers/providers.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:provider/provider.dart';

Future<void> sessionExpired(BuildContext context) async {
  Navigator.of(context).pushNamedAndRemoveUntil(
      HomeRoot.routeName, (Route<dynamic> route) => false);
  UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
  userProvider.logoutUser();
  showSnackbar(context, "Votre session a expiré, veuillez vous reconnecter.");
}
