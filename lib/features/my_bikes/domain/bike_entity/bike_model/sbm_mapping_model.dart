class SbmMapping {
  SbmMapping({
    this.id,
    this.name,
    this.statusId,
    this.tenantId,
    this.isActive,
    this.macAddress,
    this.encKeyPrimary,
    this.encKeySecondary,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.hwVer,
    this.swVer,
    this.functionality
  });

  int? id;
  String? name;
  int? statusId;
  int? tenantId;
  int? isActive;
  String? macAddress;
  String? encKeyPrimary;
  String? encKeySecondary;
  dynamic createdBy;
  dynamic updatedBy;
  dynamic createdAt;
  dynamic updatedAt;
  String? hwVer;
  String? swVer;
  SbmMappingFunctionality? functionality;

  factory SbmMapping.fromJson(Map<String, dynamic> json) => SbmMapping(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    statusId: json["status_id"] ?? 0,
    tenantId: json["tenant_id"] ?? 0,
    isActive: json["is_active"] != null ? json["is_active"] == true ? 1 : 0 : 0,
    macAddress: json["mac_address"] ?? '',
    encKeyPrimary: json["enc_key_primary"] ??'',
    encKeySecondary: json["enc_key_secondary"] ??"",
    createdBy: json["created_by"] ?? 0,
    updatedBy: json["updated_by"] ?? 0,
    createdAt: json["created_at"] ?? 0,
    updatedAt: json["updated_at"] ?? 0,
    hwVer: json["hw_ver"] ??'',
    swVer: json["sw_ver"] ??'',
    functionality: json["functionality"] != null ? SbmMappingFunctionality.fromJson(json["functionality"]) : SbmMappingFunctionality(dfuConfig: null,immobilisationEnabled: true),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "status_id": statusId,
    "tenant_id": tenantId,
    "is_active": isActive,
    "mac_address": macAddress,
    "enc_key_primary": encKeyPrimary,
    "enc_key_secondary": encKeySecondary,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "hw_ver": hwVer,
    "sw_ver": swVer,
    "functionality": functionality
  };

  @override
  String toString() {
    return 'SbmMapping{id: $id, name: $name, statusId: $statusId, tenantId: $tenantId, isActive: $isActive, macAddress: $macAddress, encKeyPrimary: $encKeyPrimary, encKeySecondary: $encKeySecondary, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt, hwVer: $hwVer, swVer: $swVer, functionality: $functionality}';
  }
}

class SbmMappingFunctionality {
  DfuConfig? dfuConfig;
  bool? immobilisationEnabled;

  SbmMappingFunctionality({
    this.dfuConfig,
    this.immobilisationEnabled,
  });

  factory SbmMappingFunctionality.fromJson(Map<String, dynamic> json) => SbmMappingFunctionality(
    dfuConfig: json["dfu_config"] == null ? null : DfuConfig.fromJson(json["dfu_config"]),
    immobilisationEnabled: json["immobilisation_enabled"] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "dfu_config": dfuConfig?.toJson(),
    "immobilisation_enabled": immobilisationEnabled,
  };

  @override
  String toString() {
    return 'SbmMappingFunctionality{dfuConfig: $dfuConfig, immobilisationEnabled: $immobilisationEnabled}';
  }
}

class DfuConfig {
  String targetFileName;
  String targetFirmware;

  DfuConfig({
    required this.targetFileName,
    required this.targetFirmware,
  });

  factory DfuConfig.fromJson(Map<String, dynamic> json) => DfuConfig(
    targetFileName: json["target_fileName"],
    targetFirmware: json["target_firmware"],
  );

  Map<String, dynamic> toJson() => {
    "target_fileName": targetFileName,
    "target_firmware": targetFirmware,
  };

  @override
  String toString() {
    return 'DfuConfig{targetFileName: $targetFileName, targetFirmware: $targetFirmware}';
  }
}