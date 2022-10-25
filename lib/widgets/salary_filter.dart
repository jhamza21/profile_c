import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class SalaryFilter extends StatefulWidget {
  final int selectedSalary;
  final void Function(int) callback;
  SalaryFilter(this.selectedSalary, this.callback);
  @override
  _SalaryFilterState createState() => _SalaryFilterState();
}

class _SalaryFilterState extends State<SalaryFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: widget.selectedSalary == null ? BLUE_LIGHT : GREY_LIGHt),
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedSalary == null
                    ? null
                    : SALARIES_FILTER[widget.selectedSalary],
                dropdownColor: BLUE_LIGHT,
                hint: Text(
                  getTranslate(context, "SALARY_FILTER"),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: (String newValue) async {
                  widget.callback(SALARIES_FILTER.indexOf(newValue));
                },
                items: SALARIES_FILTER.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value + "\$",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10.0),
            widget.selectedSalary != null
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
