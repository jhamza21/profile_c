import 'package:profilecenter/models/devise.dart';

double convertMoney(Devise deviseFrom, double money, Devise deviseTo) {
  return money * deviseFrom.rapport * deviseTo.rapport;
}
