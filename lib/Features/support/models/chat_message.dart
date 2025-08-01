class ChatMessage {
  String? ticketId;
  String? content;
  List<String>? attachmentsUrl;
  String? senderId;
  String? sentAt;

  ChatMessage({
    this.ticketId,
    this.content,
    this.attachmentsUrl,
    this.senderId,
    this.sentAt,
  });

  ChatMessage.fromJson(Map<String, dynamic> json) {
    ticketId = json['ticketId'];
    content = json['content'];
    attachmentsUrl = json['AttachmentsUrl'];
    senderId = json['senderId'];
    sentAt = json['sentAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ticketId'] = ticketId;
    data['content'] = content;
    data['AttachmentsUrl'] = attachmentsUrl;
    data['senderId'] = senderId;
    data['sentAt'] = sentAt;
    return data;
  }
}
