import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class StripeTransactionResponse {
  final String message;
  final bool success;
  StripeTransactionResponse({
    @required this.message,
    @required this.success,
  });
}

class StripeServices {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeServices.apiBase}/payment_intents';
  static Uri paymentApiUri = Uri.parse(paymentApiUrl);
  static String secret =
      'sk_test_51Jjrx9IALR9H9z91DfxSdRZyKDZWCntQQg5dTHLHG8T6F91ayrzJ6ZOfoUIGhc33Xi0uBenksGpR3WCMP9U9jucL0029IsF9ZA';

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeServices.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      var response = await http.post(paymentApiUri, headers: headers, body: {
        'amount': amount,
        'currency': currency,
      });
      return jsonDecode(response.body);
    } catch (error) {
      throw error;
    }
  }

  static Future<http.Response> createStripeAccount(String countyCode) async {
    var url = "${StripeServices.apiBase}/accounts";

    return await http.post(Uri.parse(url), headers: headers, body: {
      "country": countyCode,
      "type": "express",
      "capabilities[transfers][requested]": "true"
    });
  }

  static Future<http.Response> getAccountLink(String id) async {
    var url = "${StripeServices.apiBase}/account_links";
    return await http.post(Uri.parse(url), headers: headers, body: {
      "account": id,
      "type": "account_onboarding",
      "refresh_url": URL_BACKEND + "stripe/error",
      "return_url": URL_BACKEND + "stripe/success",
    });
  }

  static Future<http.Response> getAccount(String id) async {
    var url = "${StripeServices.apiBase}/accounts/$id";
    return await http.get(Uri.parse(url), headers: headers);
  }

  //get stripe supported countries
  static Future<http.Response> getSupportedCountries() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/countries";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}
