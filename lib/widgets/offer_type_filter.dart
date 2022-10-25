import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class OfferTypeFilter extends StatefulWidget {
  final int selectedOfferType;
  final void Function(int) callback;
  OfferTypeFilter(this.selectedOfferType, this.callback);
  @override
  _OfferTypeFilterState createState() => _OfferTypeFilterState();
}

class _OfferTypeFilterState extends State<OfferTypeFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: widget.selectedOfferType == null ? BLUE_LIGHT : GREY_LIGHt),
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedOfferType == null
                    ? null
                    : OFFER_TYPES_FILTER[widget.selectedOfferType],
                dropdownColor: BLUE_LIGHT,
                hint: Text(
                  getTranslate(context, "OFFER_TYPE_FILTER"),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: (String newValue) async {
                  widget.callback(OFFER_TYPES_FILTER.indexOf(newValue));
                },
                items: OFFER_TYPES_FILTER.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      getTranslate(context, value),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10.0),
            widget.selectedOfferType != null
                ? GestureDetector(
                    onTap: () => widget.callback(null),
                    child: Icon(
                      Icons.remove_circle,
                      color: RED_LIGHT,
                      size: 18,
                    ),
                  )
                : SizedBox.shrink()
          ],
        ));
  }
}
