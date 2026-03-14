class Valasztokerulet {
  final String id;
  final String nev;
  final String megye;
  final int oevk;

  Valasztokerulet({
    required this.id,
    required this.nev,
    required this.megye,
    required this.oevk,
  });

  factory Valasztokerulet.fromJson(Map<String, dynamic> json) {
    return Valasztokerulet(
      id: json['id'] ?? '',
      nev: json['nev'] ?? '',
      megye: json['megye'] ?? '',
      oevk: json['oevk'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nev': nev,
      'megye': megye,
      'oevk': oevk,
    };
  }
}

class Megye {
  final String nev;
  final List<Valasztokerulet> keruleteok;

  Megye({
    required this.nev,
    required this.keruleteok,
  });
}
