class LocalAds{
  String file_name;
  String file_link;

  LocalAds({required this.file_name, required this.file_link});


  factory LocalAds.fromJson(Map<String, dynamic> json) {
    return LocalAds(
        file_name: json["file_name"],
        file_link: json["file_link"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "file_name": file_name,
      "file_link": file_link,
    };
  }


}