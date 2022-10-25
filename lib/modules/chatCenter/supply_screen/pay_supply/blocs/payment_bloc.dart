import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:meta/meta.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentState()) {
    on<PaymentInit>(_onPaymentInit);
    on<PaymentCreateIntent>(_onPaymentCreateIntent);
    on<PaymentConfirmIntent>(_onPaymentConfirmIntent);
  }

  _onPaymentInit(PaymentInit event, Emitter<PaymentState> emit) async {
    emit(state.copyWith(status: PaymentStatus.initial));
  }

  _onPaymentCreateIntent(
      PaymentCreateIntent event, Emitter<PaymentState> emit) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loading));
      final paymentMethod = await Stripe.instance.createPaymentMethod(
          PaymentMethodParams.card(
              paymentMethodData:
                  PaymentMethodData(billingDetails: event.billingDetails)));
      final paymentIntentResults = await _callEndpointMethodId(
          usestripeSdk: true,
          paymentMethodId: paymentMethod.id,
          amount: event.amount);

      if (paymentIntentResults['error'] != null) {
        emit(state.copyWith(status: PaymentStatus.failure));
      } else if (paymentIntentResults['clientSecret'] != null &&
          paymentIntentResults['requiresAction'] == null) {
        emit(state.copyWith(status: PaymentStatus.success));
      } else if (paymentIntentResults['clientSecret'] != null &&
          paymentIntentResults['requiresAction'] == true) {
        final String clientSecret = paymentIntentResults['clientSecret'];
        add(PaymentConfirmIntent(clientSecret: clientSecret));
      } else {
        emit(state.copyWith(status: PaymentStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(status: PaymentStatus.failure));
    }
  }

  _onPaymentConfirmIntent(
      PaymentConfirmIntent event, Emitter<PaymentState> emit) async {
    try {
      final paymentIntent =
          await Stripe.instance.handleNextAction(event.clientSecret);
      if (paymentIntent.status == PaymentIntentsStatus.RequiresConfirmation) {
        Map<String, dynamic> results =
            await _callEndpointIntentId(paymentIntentId: paymentIntent.id);
        if (results['error'] != null) {
          emit(state.copyWith(status: PaymentStatus.failure));
        } else {
          emit(state.copyWith(status: PaymentStatus.success));
        }
      }
    } catch (e) {
      emit(state.copyWith(status: PaymentStatus.failure));
    }
  }
}

Future<Map<String, dynamic>> _callEndpointMethodId(
    {bool usestripeSdk, String paymentMethodId, int amount}) async {
  String token = await SecureStorageService.readToken();
  var url = URL_BACKEND + "api/payIntentId?api_token=" + token;
  final res = await http.post(Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        'usestripeSdk': usestripeSdk,
        'paymentMethodId': paymentMethodId,
        'amount': amount
      }));
  return json.decode(res.body);
}

Future<Map<String, dynamic>> _callEndpointIntentId(
    {String paymentIntentId}) async {
  String token = await SecureStorageService.readToken();
  var url = URL_BACKEND + "api/payMethodId?api_token=" + token;
  final res = await http.post(Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        'paymentIntentId': paymentIntentId,
      }));
  return json.decode(res.body);
}
