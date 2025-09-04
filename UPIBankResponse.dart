// To parse this JSON data, do
//
//     final bankResponseResponse = bankResponseResponseFromJson(jsonString);

import 'dart:convert';

UPIBankResponseResponse upiBankResponseResponseFromJson(String str) => UPIBankResponseResponse.fromJson(json.decode(str));

String upiBankResponseResponseToJson(UPIBankResponseResponse data) => json.encode(data.toJson());

class UPIBankResponseResponse {
  String id;
  String entity;
  int amount;
  String currency;
  String status;
  bool international;
  String? method;
  int? amountRefunded;
  String? refundStatus;
  bool? captured;
  String? description;
  dynamic cardId;
  dynamic bank;
  dynamic wallet;
  String? vpa;
  String? email;
  String? contact;
  Notes? notes;
  int? fee;
  int? tax;
  dynamic errorCode;
  dynamic errorDescription;
  dynamic errorReason;
  AcquirerData? acquirerData;
  int? createdAt;
  Upi? upi;
  dynamic reward;
  dynamic transaction;

  UPIBankResponseResponse({
    required this.id,
    required this.entity,
    required this.amount,
    required this.currency,
    required this.status,
    required this.international,
    required this.method,
     this.amountRefunded,
     this.refundStatus,
     this.captured,
     this.description,
     this.cardId,
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
     this.errorReason,
     this.acquirerData,
     this.createdAt,
     this.upi,
     this.reward,
     this.transaction,
  });

  factory UPIBankResponseResponse.fromJson(Map<String, dynamic> json) => UPIBankResponseResponse(
    id: json["id"],
    entity: json["entity"],
    amount: json["amount"],
    currency: json["currency"],
    status: json["status"],
    international: json["international"],
    method: json["method"],
    amountRefunded: json["amount_refunded"],
    refundStatus: json["refund_status"],
    captured: json["captured"],
    description: json["description"],
    cardId: json["card_id"],
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
    errorReason: json["error_reason"],
    acquirerData: AcquirerData.fromJson(json["acquirer_data"]),
    createdAt: json["created_at"],
    upi: Upi.fromJson(json["upi"]),
    reward: json["reward"],
    transaction: json["transaction"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "entity": entity,
    "amount": amount,
    "currency": currency,
    "status": status,
    "international": international,
    "method": method,
    "amount_refunded": amountRefunded,
    "refund_status": refundStatus,
    "captured": captured,
    "description": description,
    "card_id": cardId,
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
    "error_reason": errorReason,
    "acquirer_data": acquirerData!.toJson(),
    "created_at": createdAt,
    "upi": upi!.toJson(),
    "reward": reward,
    "transaction": transaction,
  };
}

class AcquirerData {
  String? rrn;

  AcquirerData({
     this.rrn,
  });

  factory AcquirerData.fromJson(Map<String, dynamic> json) => AcquirerData(
    rrn: json["rrn"],
  );

  Map<String, dynamic> toJson() => {
    "rrn": rrn,
  };
}

class Notes {
  String? mobileType;
  String? orderId;

  Notes({
     this.mobileType,
     this.orderId,
  });

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
    mobileType: json["mobile_type"],
    orderId: json["order_id"],
  );

  Map<String, dynamic> toJson() => {
    "mobile_type": mobileType,
    "order_id": orderId,
  };
}

class Upi {
  String? payerAccountType;
  String? vpa;

  Upi({
     this.payerAccountType,
     this.vpa,
  });

  factory Upi.fromJson(Map<String, dynamic> json) => Upi(
    payerAccountType: json["payer_account_type"],
    vpa: json["vpa"],
  );

  Map<String, dynamic> toJson() => {
    "payer_account_type": payerAccountType,
    "vpa": vpa,
  };
}
