import 'package:tendria/features/user/domain/entities/create_reports_user_entity.dart';

class CreateReportsUserModel extends CreateReportsUserEntity {
  CreateReportsUserModel({required super.reportedid, required super.reason, required super.description});

  factory CreateReportsUserModel.fromJson(Map<String, dynamic> json) {
    return CreateReportsUserModel(
      reportedid: json['reportedid'],
      reason: json['reason'],
      description: json['description'],
    );
  }
  factory CreateReportsUserModel.fromEntity(CreateReportsUserEntity entity) {
    return CreateReportsUserModel(
      reportedid: entity.reportedid,
      reason: entity.reason,
      description: entity.description,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'reportado_id': reportedid,
      'motivo': reason,
      'descripcion': description,
    };
  }
}