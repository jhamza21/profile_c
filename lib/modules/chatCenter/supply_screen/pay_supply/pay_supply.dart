import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:profilecenter/modules/chatCenter/supply_screen/pay_supply/blocs/payment_bloc.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:provider/provider.dart';

class PaySupply extends StatefulWidget {
  static const routeName = '/paySupply';

  final PaySupplyArguments arguments;
  const PaySupply({Key key, @required this.arguments}) : super(key: key);

  @override
  State<PaySupply> createState() => _PaySupplyState();
}

class _PaySupplyState extends State<PaySupply> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(),
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state.status == PaymentStatus.failure) {
            context.read<PaymentBloc>().add(PaymentInit());
            showSnackbar(context, "Le paiement a echoué");
          } else if (state.status == PaymentStatus.success) {
            Navigator.of(context).pop();
            widget.arguments.onCallback();
          }
        },
        builder: (context, state) {
          CardFormEditController controller = CardFormEditController(
              initialDetails: state.cardFieldInputDetails);
          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Approvisionner ${widget.arguments.amount}"),
                  const SizedBox(height: 20.0),
                  CardFormField(
                      controller: controller,
                      style: CardFormStyle(backgroundColor: Colors.white)),
                  const SizedBox(height: 20.0),
                  TextButton(
                      onPressed: state.status == PaymentStatus.loading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              UserProvider userProvider =
                                  Provider.of<UserProvider>(context,
                                      listen: false);
                              if (controller.details.complete) {
                                context.read<PaymentBloc>().add(
                                    PaymentCreateIntent(
                                        billingDetails:
                                            BillingDetails(
                                                email: userProvider.user.email),
                                        amount: (widget.arguments.amount * 100)
                                            .toInt()));
                              } else {
                                showSnackbar(context, "Remplir le formulaire");
                              }
                            },
                      child: Text("Payer")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PaySupplyArguments {
  final double amount;
  final void Function() onCallback;

  const PaySupplyArguments({@required this.amount, @required this.onCallback});
}
