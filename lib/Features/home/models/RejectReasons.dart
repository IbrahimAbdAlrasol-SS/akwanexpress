class RejectReason {
  String? reason;
  bool? isActive;
  String? id;
  bool? deleted;
  String? creationDate;

  RejectReason(
      {this.reason, this.isActive, this.id, this.deleted, this.creationDate});

  RejectReason.fromJson(Map<String, dynamic> json) {
    reason = json['reason'];
    isActive = json['isActive'];
    id = json['id'];
    deleted = json['deleted'];
    creationDate = json['creationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reason'] = this.reason;
    data['isActive'] = this.isActive;
    data['id'] = this.id;
    data['deleted'] = this.deleted;
    data['creationDate'] = this.creationDate;
    return data;
  }
}
