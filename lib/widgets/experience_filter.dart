import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class ExperienceFilter extends StatefulWidget {
  final int selectedExperience;
  final void Function(int) callback;
  ExperienceFilter(this.selectedExperience, this.callback);
  @override
  _ExperienceFilterState createState() => _ExperienceFilterState();
}

class _ExperienceFilterState extends State<ExperienceFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: widget.selectedExperience == null ? BLUE_LIGHT : GREY_LIGHt),
        padding: EdgeInsets.only(left: 20, right: 10),
        child: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedExperience == null
                    ? null
                    : EXPERIENCES_FILTER[widget.selectedExperience],
                dropdownColor: BLUE_LIGHT,
                hint: Text(
                  getTranslate(context, "EXPERIENCE"),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: (String newValue) async {
                  widget.callback(EXPERIENCES_FILTER.indexOf(newValue));
                },
                items: EXPERIENCES_FILTER.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10.0),
            widget.selectedExperience != null
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
