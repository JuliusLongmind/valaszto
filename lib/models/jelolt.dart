class Jelolt {
  final String id;
  final String nev;
  final String? kepUrl;
  final String? rovidUzenet;
  final String? teljesUzenet;
  final String part;
  final String valasztokeruletId;
  final String valasztokeruletNev;
  final int sorszam;
  final bool verificated;

  Jelolt({
    required this.id,
    required this.nev,
    this.kepUrl,
    this.rovidUzenet,
    this.teljesUzenet,
    required this.part,
    required this.valasztokeruletId,
    required this.valasztokeruletNev,
    required this.sorszam,
    this.verificated = false,
  });

  factory Jelolt.fromJson(Map<String, dynamic> json) {
    return Jelolt(
      id: json['id'] ?? '',
      nev: json['nev'] ?? '',
      kepUrl: json['kepUrl'],
      rovidUzenet: json['rovidUzenet'],
      teljesUzenet: json['teljesUzenet'],
      part: json['part'] ?? '',
      valasztokeruletId: json['valasztokeruletId'] ?? '',
      valasztokeruletNev: json['valasztokeruletNev'] ?? '',
      sorszam: json['sorszam'] ?? 0,
      verificated: json['verificated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nev': nev,
      'kepUrl': kepUrl,
      'rovidUzenet': rovidUzenet,
      'teljesUzenet': teljesUzenet,
      'part': part,
      'valasztokeruletId': valasztokeruletId,
      'valasztokeruletNev': valasztokeruletNev,
      'sorszam': sorszam,
      'verificated': verificated,
    };
  }
}
