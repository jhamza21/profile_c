part of 'payment_bloc.dart';

@immutable
abstract class PaymentEvent {}

class PaymentInit extends PaymentEvent {}

class PaymentCreateIntent extends PaymentEvent {
  final BillingDetails billingDetails;
  final int amount;
  PaymentCreateIntent({@required this.billingDetails, @required this.amount});
}

class PaymentConfirmIntent extends PaymentEvent {
  final String clientSecret;
  PaymentConfirmIntent({@required this.clientSecret});
}
