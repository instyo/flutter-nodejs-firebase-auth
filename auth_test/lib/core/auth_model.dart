// To parse this JSON data, do
//
//     final authModel = authModelFromJson(jsonString);

import 'dart:convert';

AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));

String authModelToJson(AuthModel data) => json.encode(data.toJson());

class AuthModel {
    final String? uid;
    final String? email;
    final bool? emailVerified;
    final bool? isAnonymous;
    final StsTokenManager? stsTokenManager;
    final String? createdAt;
    final String? lastLoginAt;
    final String? apiKey;
    final String? appName;

    AuthModel({
        this.uid,
        this.email,
        this.emailVerified,
        this.isAnonymous,
        this.stsTokenManager,
        this.createdAt,
        this.lastLoginAt,
        this.apiKey,
        this.appName,
    });

    AuthModel copyWith({
        String? uid,
        String? email,
        bool? emailVerified,
        bool? isAnonymous,
        StsTokenManager? stsTokenManager,
        String? createdAt,
        String? lastLoginAt,
        String? apiKey,
        String? appName,
    }) => 
        AuthModel(
            uid: uid ?? this.uid,
            email: email ?? this.email,
            emailVerified: emailVerified ?? this.emailVerified,
            isAnonymous: isAnonymous ?? this.isAnonymous,
            stsTokenManager: stsTokenManager ?? this.stsTokenManager,
            createdAt: createdAt ?? this.createdAt,
            lastLoginAt: lastLoginAt ?? this.lastLoginAt,
            apiKey: apiKey ?? this.apiKey,
            appName: appName ?? this.appName,
        );

    factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        uid: json["uid"],
        email: json["email"],
        emailVerified: json["emailVerified"],
        isAnonymous: json["isAnonymous"],
        stsTokenManager: json["stsTokenManager"] == null ? null : StsTokenManager.fromJson(json["stsTokenManager"]),
        createdAt: json["createdAt"],
        lastLoginAt: json["lastLoginAt"],
        apiKey: json["apiKey"],
        appName: json["appName"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "emailVerified": emailVerified,
        "isAnonymous": isAnonymous,
        "stsTokenManager": stsTokenManager?.toJson(),
        "createdAt": createdAt,
        "lastLoginAt": lastLoginAt,
        "apiKey": apiKey,
        "appName": appName,
    };
}

class StsTokenManager {
    final String? refreshToken;
    final String? accessToken;
    final int? expirationTime;

    StsTokenManager({
        this.refreshToken,
        this.accessToken,
        this.expirationTime,
    });

    StsTokenManager copyWith({
        String? refreshToken,
        String? accessToken,
        int? expirationTime,
    }) => 
        StsTokenManager(
            refreshToken: refreshToken ?? this.refreshToken,
            accessToken: accessToken ?? this.accessToken,
            expirationTime: expirationTime ?? this.expirationTime,
        );

    factory StsTokenManager.fromJson(Map<String, dynamic> json) => StsTokenManager(
        refreshToken: json["refreshToken"],
        accessToken: json["accessToken"],
        expirationTime: json["expirationTime"],
    );

    Map<String, dynamic> toJson() => {
        "refreshToken": refreshToken,
        "accessToken": accessToken,
        "expirationTime": expirationTime,
    };
}
