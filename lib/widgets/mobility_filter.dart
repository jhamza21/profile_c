import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class MobilityFilter extends StatefulWidget {
  final int selectedMobility;
  final void Function(int) callback;
  MobilityFilter(this.selectedMobility, this.callback);
  @override
  _MobilityFilterState createState() => _MobilityFilterState();
}

class _MobilityFilterState extends State<MobilityFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: widget.selectedMobility == null ? BLUE_LIGHT : GREY_LIGHt),
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedMobility == null
                    ? null
                    : MOBILITIES_FILTER[widget.selectedMobility],
                dropdownColor: BLUE_LIGHT,
                hint: Text(
                  getTranslate(context, "MOBILITY_FILTER"),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: (String newValue) async {
                  widget.callback(MOBILITIES_FILTER.indexOf(newValue));
                },
                items: MOBILITIES_FILTER.map((String value) {
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
            widget.selectedMobility != null
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
