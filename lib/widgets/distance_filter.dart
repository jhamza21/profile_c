import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:provider/provider.dart';

class DistanceFilter extends StatefulWidget {
  final int selectedDistance;
  final void Function(int) callback;
  DistanceFilter(this.selectedDistance, this.callback);
  @override
  _DistanceFilterState createState() => _DistanceFilterState();
}

class _DistanceFilterState extends State<DistanceFilter> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: widget.selectedDistance == null ? BLUE_LIGHT : GREY_LIGHt),
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedDistance == null
                    ? null
                    : DISTANCES_FILTER[widget.selectedDistance],
                dropdownColor: BLUE_LIGHT,
                hint: Text(
                  getTranslate(context, "DISTANCE"),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: userProvider.user.address == null
                    ? null
                    : (String newValue) async {
                        widget.callback(DISTANCES_FILTER.indexOf(newValue));
                      },
                items: DISTANCES_FILTER.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      "< " + value + " km",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10.0),
            widget.selectedDistance != null
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
