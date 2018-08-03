class OperationModel {
  int id;
  String key;

  String title;
  String message;
  int time;
  String destination;

  num destinationLat;
  num destinationLng;

  OperationModel();

  Map toMap() {
    Map<String, dynamic> map = {
      "title": title,
      "message": message,
      "key": key,
      "time": time,
      "destination": destination,
      "destinationLat": destinationLat,
      "destinationLng": destinationLng
    };
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }

  OperationModel.fromMap(Map map) {
    id = map["id"];
    title = map["title"];
    message = map["message"];
    key = map["key"];
    time = map["time"];
    destination = map["destination"];
    destinationLat = map["destinationLat"];
    destinationLng = map["destinationLng"];
  }

  @override
  String toString() {
    return 'OperationModel{id: $id, key: $key, title: $title, message: $message, time: $time, destination: $destination, destinationLat: $destinationLat, destinationLng: $destinationLng}';
  }
}
