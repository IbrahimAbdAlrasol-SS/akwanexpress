class ChatMessage {
  String? id;
  String? ticketId;
  String? content;
  List<String>? attachmentsUrl;
  String? senderId;
  String? sentAt;
  bool isDelivered;
  bool isRead;

  ChatMessage({
    this.id,
    this.ticketId,
    this.content,
    this.attachmentsUrl,
    this.senderId,
    this.sentAt,
    this.isDelivered = false,
    this.isRead = false,
  });

  ChatMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        ticketId = json['ticketId'],
        content = json['content'],
        attachmentsUrl = json['AttachmentsUrl'] != null
            ? List<String>.from(json['AttachmentsUrl'])
            : null,
        senderId = json['senderId'],
        sentAt = json['sentAt'],
        isDelivered = json['isDelivered'] ?? false,
        isRead = json['isRead'] ?? false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ticketId'] = ticketId;
    data['content'] = content;
    data['AttachmentsUrl'] = attachmentsUrl;
    data['senderId'] = senderId;
    data['sentAt'] = sentAt;
    data['isDelivered'] = isDelivered;
    data['isRead'] = isRead;
    return data;
  }

  ChatMessage copyWith({
    String? id,
    String? ticketId,
    String? content,
    List<String>? attachmentsUrl,
    String? senderId,
    String? sentAt,
    bool? isDelivered,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      content: content ?? this.content,
      attachmentsUrl: attachmentsUrl ?? this.attachmentsUrl,
      senderId: senderId ?? this.senderId,
      sentAt: sentAt ?? this.sentAt,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
    );
  }
}
