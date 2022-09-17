class LessonModel {
  String number;
  String title;
  String office;
  String startLessonTime;
  String endLessonTime;

  LessonModel(
      {required this.number,
      required this.title,
      required this.office,
      required this.startLessonTime,
      required this.endLessonTime});

  /*factory MeetingModel.fromJson(dynamic json) {
    return MeetingModel(
      id: json['id'],
      hostId: json['hostId'],
      hostName: json['hostName'],
    );
  }*/
}
