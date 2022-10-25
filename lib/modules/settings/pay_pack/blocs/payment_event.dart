part of 'payment_bloc.dart';

@immutable
abstract class PaymentEvent {}

class PaymentInit extends PaymentEvent {}

class PaymentCreateIntent extends PaymentEvent {
  final BillingDetails billingDetails;
  final int packId;
  PaymentCreateIntent({@required this.billingDetails, @required this.packId});
}

class PaymentConfirmIntent extends PaymentEvent {
  final int packId;
  final String clientSecret;
  PaymentConfirmIntent({@required this.clientSecret, @required this.packId});
}
