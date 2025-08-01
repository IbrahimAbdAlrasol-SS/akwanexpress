class Ticket {
  String? id;
  String? subject;
  String? description;
  int? status;

  String? referenceId;

  Ticket({this.description, this.referenceId, this.subject, this.id});

  Ticket.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subject = json['subject'];
    description = json['description'];
    referenceId = json['referenceId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = description;
    data['subject'] = subject;
    data['referenceId'] = referenceId;
    data['status'] = status;

    return data;
  }
}
