import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class RoleFilter extends StatefulWidget {
  final int selectedRole;
  final void Function(int) callback;
  RoleFilter(this.selectedRole, this.callback);
  @override
  _RoleFilterState createState() => _RoleFilterState();
}

class _RoleFilterState extends State<RoleFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: widget.selectedRole == null ? BLUE_LIGHT : GREY_LIGHt),
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedRole == null
                    ? null
                    : ROLES_FILTER[widget.selectedRole],
                dropdownColor: BLUE_LIGHT,
                hint: Text(
                  getTranslate(context, "ROLE_FILTER"),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: (String newValue) async {
                  widget.callback(ROLES_FILTER.indexOf(newValue));
                },
                items: ROLES_FILTER.map((String value) {
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
            widget.selectedRole != null
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
