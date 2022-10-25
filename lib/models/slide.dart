import 'package:flutter/material.dart';

class Slide {
  final String title;
  final String description;

  Slide({
    @required this.title,
    @required this.description,
  });
}

final slideList = [
  Slide(
    title: 'FIND_A_JOB_OR_MISSION',
    description: 'FIND_A_JOB_OR_MISSION_DESCRIPTION',
  ),
  Slide(
    title: 'FIND_THE_RIGHT_JOB',
    description: 'FIND_THE_RIGHT_JOB_DESCRIPTION',
  ),
  Slide(
    title: 'NO_TRACAS',
    description: 'NO_TRACAS_DESCRIPTION',
  ),
  Slide(
    title: 'YOU_ARE_NOT_ALONE',
    description: 'YOU_ARE_NOT_ALONE_DESCRIPTION',
  ),
];
