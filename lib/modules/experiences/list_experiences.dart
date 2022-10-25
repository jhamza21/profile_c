import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/experience_provider.dart';
import 'package:profilecenter/modules/experiences/add_update_experience.dart';
import 'package:profilecenter/widgets/empty_data_card.dart';
import 'package:profilecenter/modules/experiences/experience_card.dart';
import 'package:provider/provider.dart';

class ListExperiences extends StatefulWidget {
  @override
  _ListExperiencesState createState() => _ListExperiencesState();
}

class _ListExperiencesState extends State<ListExperiences> {
  @override
  Widget build(BuildContext context) {
    ExperienceProvider experienceProvider =
        Provider.of<ExperienceProvider>(context, listen: true);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getTranslate(context, "EXPERIENCES"),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AddUpdateExperience.routeName),
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                )),
          ],
        ),
        experienceProvider.experiences.length != 0
            ? ListView.builder(
                itemCount: experienceProvider.experiences.length,
                reverse: true,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ExperienceCard(
                      experience: experienceProvider.experiences[index],
                      readOnly: false);
                })
            : EmptyDataCard(getTranslate(context, "NO_DATA")),
      ],
    );
  }
}
