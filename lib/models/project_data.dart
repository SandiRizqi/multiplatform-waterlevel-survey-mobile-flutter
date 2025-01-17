class Project {
  final String name;
  final String description;
  final List<ProjectData> dataList;

  Project({required this.name, required this.description}) : dataList = [];

  // Convert a Project object into a Map object
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'dataList': dataList.map((data) => data.toJson()).toList(),
      };

  // Create a Project object from a Map object
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'],
      description: json['description'],
    )..dataList.addAll((json['dataList'] as List)
        .map((dataJson) => ProjectData.fromJson(dataJson))
        .toList());
  }
}

class ProjectData {
  final String code;
  final double longitude;
  final double latitude;
  final double nilai;

  ProjectData({
    required this.code,
    required this.longitude,
    required this.latitude,
    required this.nilai,
  });

  // Convert a ProjectData object into a Map object
  Map<String, dynamic> toJson() => {
        'code': code,
        'longitude': longitude,
        'latitude': latitude,
        'nilai': nilai,
      };

  // Create a ProjectData object from a Map object
  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      code: json['code'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      nilai: json['nilai'],
    );
  }
}
