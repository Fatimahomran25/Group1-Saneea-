class AnnouncementModel {
  String query;

  AnnouncementModel({this.query = ''});

  AnnouncementModel copyWith({String? query}) {
    return AnnouncementModel(query: query ?? this.query);
  }
}
