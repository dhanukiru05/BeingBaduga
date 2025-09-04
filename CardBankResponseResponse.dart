// To parse this JSON data, do
//
//     final cardBankResponseResponse = cardBankResponseResponseFromJson(jsonString);

import 'dart:convert';

CardBankResponseResponse cardBankResponseResponseFromJson(String str) => CardBankResponseResponse.fromJson(json.decode(str));

String cardBankResponseResponseToJson(CardBankResponseResponse data) => json.encode(data.toJson());

class CardBankResponseResponse {
  String id;
  String entity;
  int amount;
  String currency;
  String status;
  dynamic invoiceId;
  bool? international;
  String? method;
  int? amountRefunded;
  dynamic refundStatus;
  bool? captured;
  String? description;
  String? cardId;
  CardData? cardData;
  dynamic bank;
  dynamic wallet;
  dynamic vpa;
  String? email;
  String? contact;
  Notes? notes;
  int? fee;
  int? tax;
  dynamic errorCode;
  dynamic errorDescription;
  dynamic errorSource;
  dynamic errorStep;
  dynamic errorReason;
  AcquirerData? acquirerData;
  int? createdAt;
  Authentication? authentication;
  dynamic transaction;

  CardBankResponseResponse({
    required this.id,
    required this.entity,
    required this.amount,
    required this.currency,
    required this.status,
     this.invoiceId,
     this.international,
     this.method,
     this.amountRefunded,
     this.refundStatus,
     this.captured,
     this.description,
     this.cardId,
     this.cardData,
     this.bank,
     this.wallet,
     this.vpa,
     this.email,
     this.contact,
     this.notes,
     this.fee,
     this.tax,
     this.errorCode,
     this.errorDescription,
     this.errorSource,
     this.errorStep,
     this.errorReason,
     this.acquirerData,
     this.createdAt,
     this.authentication,
     this.transaction,
  });

  factory CardBankResponseResponse.fromJson(Map<String, dynamic> json) => CardBankResponseResponse(
    id: json["id"],
    entity: json["entity"],
    amount: json["amount"],
    currency: json["currency"],
    status: json["status"],
    invoiceId: json["invoice_id"],
    international: json["international"],
    method: json["method"],
    amountRefunded: json["amount_refunded"],
    refundStatus: json["refund_status"],
    captured: json["captured"],
    description: json["description"],
    cardId: json["card_id"],
    cardData: CardData.fromJson(json["card"]),
    bank: json["bank"],
    wallet: json["wallet"],
    vpa: json["vpa"],
    email: json["email"],
    contact: json["contact"],
    notes: Notes.fromJson(json["notes"]),
    fee: json["fee"],
    tax: json["tax"],
    errorCode: json["error_code"],
    errorDescription: json["error_description"],
    errorSource: json["error_source"],
    errorStep: json["error_step"],
    errorReason: json["error_reason"],
    acquirerData: AcquirerData.fromJson(json["acquirer_data"]),
    createdAt: json["created_at"],
    authentication: Authentication.fromJson(json["authentication"]),
    transaction: json["transaction"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "entity": entity,
    "amount": amount,
    "currency": currency,
    "status": status,
    "invoice_id": invoiceId,
    "international": international,
    "method": method,
    "amount_refunded": amountRefunded,
    "refund_status": refundStatus,
    "captured": captured,
    "description": description,
    "card_id": cardId,
    "card": cardData!.toJson(),
    "bank": bank,
    "wallet": wallet,
    "vpa": vpa,
    "email": email,
    "contact": contact,
    "notes": notes!.toJson(),
    "fee": fee,
    "tax": tax,
    "error_code": errorCode,
    "error_description": errorDescription,
    "error_source": errorSource,
    "error_step": errorStep,
    "error_reason": errorReason,
    "acquirer_data": acquirerData!.toJson(),
    "created_at": createdAt,
    "authentication": authentication!.toJson(),
    "transaction": transaction,
  };
}

class AcquirerData {
  String? authCode;
  String? rrn;

  AcquirerData({
     this.authCode,
     this.rrn,
  });

  factory AcquirerData.fromJson(Map<String, dynamic> json) => AcquirerData(
    authCode: json["auth_code"],
    rrn: json["rrn"],
  );

  Map<String, dynamic> toJson() => {
    "auth_code": authCode,
    "rrn": rrn,
  };
}

class Authentication {
  String? version;
  String? authenticationChannel;

  Authentication({
     this.version,
     this.authenticationChannel,
  });

  factory Authentication.fromJson(Map<String, dynamic> json) => Authentication(
    version: json["version"],
    authenticationChannel: json["authentication_channel"],
  );

  Map<String, dynamic> toJson() => {
    "version": version,
    "authentication_channel": authenticationChannel,
  };
}

class CardData {
  String? id;
  String? entity;
  String? name;
  String? last4;
  String? network;
  String? type;
  String? issuer;
  bool? international;
  bool? emi;
  String? subType;

  CardData({
     this.id,
     this.entity,
     this.name,
     this.last4,
     this.network,
     this.type,
     this.issuer,
     this.international,
     this.emi,
     this.subType,
  });

  factory CardData.fromJson(Map<String, dynamic> json) => CardData(
    id: json["id"],
    entity: json["entity"],
    name: json["name"],
    last4: json["last4"],
    network: json["network"],
    type: json["type"],
    issuer: json["issuer"],
    international: json["international"],
    emi: json["emi"],
    subType: json["sub_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "entity": entity,
    "name": name,
    "last4": last4,
    "network": network,
    "type": type,
    "issuer": issuer,
    "international": international,
    "emi": emi,
    "sub_type": subType,
  };
}

class Notes {
  String? categoryId;
  String? mobileType;
  String? orderId;
  String? packageId;
  String? userId;

  Notes({
     this.categoryId,
     this.mobileType,
     this.orderId,
     this.packageId,
     this.userId,
  });

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
    categoryId: json["category_id"],
    mobileType: json["mobile_type"],
    orderId: json["order_id"],
    packageId: json["package_id"],
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "mobile_type": mobileType,
    "order_id": orderId,
    "package_id": packageId,
    "user_id": userId,
  };
}
