import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/jelolt.dart';
import '../models/valasztokerulet.dart';

class ValasztasService {
  List<Jelolt> _cacheJeloltek = [];
  List<Valasztokerulet> _cacheKeruletek = [];
  bool _isLoaded = false;
  bool _useScraper = false;

  List<Jelolt> get jeloltek => _cacheJeloltek;
  List<Valasztokerulet> get keruletek => _cacheKeruletek;
  bool get isLoaded => _isLoaded;
  bool get isUsingRealData => _useScraper;

  Future<void> loadData() async {
    if (_isLoaded) return;
    
    await _loadFromAssets();
    _isLoaded = true;
  }

  Future<void> refreshFromApi() async {
    _isLoaded = false;
    await loadData();
  }

  Future<void> _loadFromAssets() async {
    try {
      final jeloltekJson = await rootBundle.loadString('data/jeloltek.json');
      final keruletekJson = await rootBundle.loadString('data/keruletek.json');
      
      final List<dynamic> jeloltekList = json.decode(jeloltekJson);
      final List<dynamic> keruletekList = json.decode(keruletekJson);
      
      _cacheJeloltek = jeloltekList.map((j) => Jelolt.fromJson(j)).toList();
      _cacheKeruletek = keruletekList.map((k) => Valasztokerulet.fromJson(k)).toList();
      _useScraper = true;
      print('Loaded ${_cacheJeloltek.length} candidates and ${_cacheKeruletek.length} districts from JSON');
    } catch (e) {
      print('Error loading JSON: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    _cacheKeruletek = _getAllKeruletek();
    _cacheJeloltek = _getAllJeloltek();
  }

  List<Valasztokerulet> _getAllKeruletek() {
    final List<Map<String, dynamic>> keruletekData = [
      {'megye': 'BÁCS-KISKUN', 'oevk': 1}, {'megye': 'BÁCS-KISKUN', 'oevk': 2},
      {'megye': 'BÁCS-KISKUN', 'oevk': 3}, {'megye': 'BÁCS-KISKUN', 'oevk': 4},
      {'megye': 'BÁCS-KISKUN', 'oevk': 5}, {'megye': 'BÁCS-KISKUN', 'oevk': 6},
      {'megye': 'BARANYA', 'oevk': 1}, {'megye': 'BARANYA', 'oevk': 2},
      {'megye': 'BARANYA', 'oevk': 3}, {'megye': 'BARANYA', 'oevk': 4},
      {'megye': 'BÉKÉS', 'oevk': 1}, {'megye': 'BÉKÉS', 'oevk': 2},
      {'megye': 'BÉKÉS', 'oevk': 3}, {'megye': 'BÉKÉS', 'oevk': 4},
      {'megye': 'BORSOD-ABAÚJ-ZEMPLÉN', 'oevk': 1}, {'megye': 'BORSOD-ABAÚJ-ZEMPLÉN', 'oevk': 2},
      {'megye': 'BORSOD-ABAÚJ-ZEMPLÉN', 'oevk': 3}, {'megye': 'BORSOD-ABAÚJ-ZEMPLÉN', 'oevk': 4},
      {'megye': 'BORSOD-ABAÚJ-ZEMPLÉN', 'oevk': 5}, {'megye': 'BORSOD-ABAÚJ-ZEMPLÉN', 'oevk': 6},
      {'megye': 'BORSOD-ABAÚJ-ZEMPLÉN', 'oevk': 7},
      {'megye': 'BUDAPEST', 'oevk': 1}, {'megye': 'BUDAPEST', 'oevk': 2},
      {'megye': 'BUDAPEST', 'oevk': 3}, {'megye': 'BUDAPEST', 'oevk': 4},
      {'megye': 'BUDAPEST', 'oevk': 5}, {'megye': 'BUDAPEST', 'oevk': 6},
      {'megye': 'BUDAPEST', 'oevk': 7}, {'megye': 'BUDAPEST', 'oevk': 8},
      {'megye': 'BUDAPEST', 'oevk': 9}, {'megye': 'BUDAPEST', 'oevk': 10},
      {'megye': 'BUDAPEST', 'oevk': 11}, {'megye': 'BUDAPEST', 'oevk': 12},
      {'megye': 'BUDAPEST', 'oevk': 13}, {'megye': 'BUDAPEST', 'oevk': 14},
      {'megye': 'BUDAPEST', 'oevk': 15}, {'megye': 'BUDAPEST', 'oevk': 16},
      {'megye': 'CSONGRÁD-CSANÁD', 'oevk': 1}, {'megye': 'CSONGRÁD-CSANÁD', 'oevk': 2},
      {'megye': 'CSONGRÁD-CSANÁD', 'oevk': 3}, {'megye': 'CSONGRÁD-CSANÁD', 'oevk': 4},
      {'megye': 'FEJÉR', 'oevk': 1}, {'megye': 'FEJÉR', 'oevk': 2},
      {'megye': 'FEJÉR', 'oevk': 3}, {'megye': 'FEJÉR', 'oevk': 4},
      {'megye': 'FEJÉR', 'oevk': 5},
      {'megye': 'GYŐR-MOSON-SOPRON', 'oevk': 1}, {'megye': 'GYŐR-MOSON-SOPRON', 'oevk': 2},
      {'megye': 'GYŐR-MOSON-SOPRON', 'oevk': 3}, {'megye': 'GYŐR-MOSON-SOPRON', 'oevk': 4},
      {'megye': 'GYŐR-MOSON-SOPRON', 'oevk': 5},
      {'megye': 'HAJDÚ-BIHAR', 'oevk': 1}, {'megye': 'HAJDÚ-BIHAR', 'oevk': 2},
      {'megye': 'HAJDÚ-BIHAR', 'oevk': 3}, {'megye': 'HAJDÚ-BIHAR', 'oevk': 4},
      {'megye': 'HAJDÚ-BIHAR', 'oevk': 5},
      {'megye': 'HEVES', 'oevk': 1}, {'megye': 'HEVES', 'oevk': 2},
      {'megye': 'HEVES', 'oevk': 3},
      {'megye': 'JÁSZ-NAGYKUN-SZOLNOK', 'oevk': 1}, {'megye': 'JÁSZ-NAGYKUN-SZOLNOK', 'oevk': 2},
      {'megye': 'JÁSZ-NAGYKUN-SZOLNOK', 'oevk': 3}, {'megye': 'JÁSZ-NAGYKUN-SZOLNOK', 'oevk': 4},
      {'megye': 'KOMÁROM-ESZTERGOM', 'oevk': 1}, {'megye': 'KOMÁROM-ESZTERGOM', 'oevk': 2},
      {'megye': 'KOMÁROM-ESZTERGOM', 'oevk': 3},
      {'megye': 'NÓGRÁD', 'oevk': 1}, {'megye': 'NÓGRÁD', 'oevk': 2},
      {'megye': 'PEST', 'oevk': 1}, {'megye': 'PEST', 'oevk': 2}, {'megye': 'PEST', 'oevk': 3},
      {'megye': 'PEST', 'oevk': 4}, {'megye': 'PEST', 'oevk': 5}, {'megye': 'PEST', 'oevk': 6},
      {'megye': 'PEST', 'oevk': 7}, {'megye': 'PEST', 'oevk': 8}, {'megye': 'PEST', 'oevk': 9},
      {'megye': 'PEST', 'oevk': 10}, {'megye': 'PEST', 'oevk': 11}, {'megye': 'PEST', 'oevk': 12},
      {'megye': 'SOMOGY', 'oevk': 1}, {'megye': 'SOMOGY', 'oevk': 2},
      {'megye': 'SOMOGY', 'oevk': 3}, {'megye': 'SOMOGY', 'oevk': 4},
      {'megye': 'SZABOLCS-SZATMÁR-BEREG', 'oevk': 1}, {'megye': 'SZABOLCS-SZATMÁR-BEREG', 'oevk': 2},
      {'megye': 'SZABOLCS-SZATMÁR-BEREG', 'oevk': 3}, {'megye': 'SZABOLCS-SZATMÁR-BEREG', 'oevk': 4},
      {'megye': 'SZABOLCS-SZATMÁR-BEREG', 'oevk': 5}, {'megye': 'SZABOLCS-SZATMÁR-BEREG', 'oevk': 6},
      {'megye': 'TOLNA', 'oevk': 1}, {'megye': 'TOLNA', 'oevk': 2},
      {'megye': 'TOLNA', 'oevk': 3},
      {'megye': 'VAS', 'oevk': 1}, {'megye': 'VAS', 'oevk': 2},
      {'megye': 'VAS', 'oevk': 3},
      {'megye': 'VESZPRÉM', 'oevk': 1}, {'megye': 'VESZPRÉM', 'oevk': 2},
      {'megye': 'VESZPRÉM', 'oevk': 3}, {'megye': 'VESZPRÉM', 'oevk': 4},
      {'megye': 'ZALA', 'oevk': 1}, {'megye': 'ZALA', 'oevk': 2},
      {'megye': 'ZALA', 'oevk': 3},
    ];

    return keruletekData.asMap().entries.map((entry) {
      final id = '${entry.key.toString().padLeft(2, '0')}';
      return Valasztokerulet(
        id: id,
        nev: '${entry.value['megye']}, ${entry.value['oevk']}. számú OEVK',
        megye: entry.value['megye'],
        oevk: entry.value['oevk'],
      );
    }).toList();
  }

  List<Jelolt> _getAllJeloltek() {
    final List<Jelolt> jeloltek = [];
    final parts = ['FIDESZ-KDNP', 'TISZA', 'DK', 'Mi Hazánk', 'Jobbik', 'MKKP', 'Munkáspárt', 'Független'];
    
    int id = 1;
    
    for (final kerulet in _cacheKeruletek) {
      final numCandidates = 4 + (id % 4);
      final startNum = id * 10;
      
      for (int i = 0; i < numCandidates; i++) {
        final part = parts[i % parts.length];
        jeloltek.add(_createJelolt(
          id: id.toString(),
          kerulet: kerulet,
          sorszam: i + 1,
          part: part,
          isVerified: i < 3,
        ));
        id++;
      }
    }
    
    return jeloltek;
  }

  Jelolt _createJelolt({
    required String id,
    required Valasztokerulet kerulet,
    required int sorszam,
    required String part,
    required bool isVerified,
  }) {
    final nameData = _getNameByPart(part);
    final imgId = int.parse(id) % 70 + 1;
    final imageUrl = 'https://randomuser.me/api/portraits/men/$imgId.jpg';
    
    return Jelolt(
      id: id,
      nev: nameData['nev']!,
      kepUrl: imageUrl,
      rovidUzenet: nameData['rovid']!,
      teljesUzenet: nameData['teljes']!,
      part: part,
      valasztokeruletId: kerulet.id,
      valasztokeruletNev: kerulet.nev,
      sorszam: sorszam,
      verificated: isVerified,
    );
  }

  Map<String, String> _getNameByPart(String part) {
    final Map<String, Map<String, String>> namesByPart = {
      'FIDESZ-KDNP': {
        'nev': 'Kovács János',
        'rovid': 'Budapest erős, Magyarország erős. Folytatjuk a fejlesztéseket!',
        'teljes': 'Országunknak stabil kormányzásra van szüksége. A Fidesz-KDNP programja a családok támogatására, a gazdaság fejlesztésére és a nemzeti érdekek védelmére épül. Kecskemét és a térség fejlesztése az elmúlt években is prioritás volt, és ez így marad a következő ciklusban is.',
      },
      'TISZA': {
        'nev': 'Nagy Mária',
        'rovid': 'Tisztességes politizálás, átláthatóság és a helyi közösségek erősítése.',
        'teljes': 'A Tisza Párt célja, hogy visszaadjuk a hitet a magyar embereknek abban, hogy változás lehetséges. Átlátható, korrupciómentes kormányzást akarunk, ahol a politika nem a haveroknak, hanem az embereknek dolgozik. A helyi közösségek megerősítése a programunk alapja.',
      },
      'DK': {
        'nev': 'Dr. Szabó Péter',
        'rovid': 'A DK a szociális igazságosságért küzd. Erősebb egészségügy, oktatás.',
        'teljes': 'A Demokratikus Koalíció programja a szociális igazságosságra épül. Erősebb egészségügy, ingyenes oktatás, tisztességes nyugdíjrendszer - ezek a prioritásaink. Magyarországnak változásra van szüksége, és mi készek vagyunk ezt véghezvinni.',
      },
      'Mi Hazánk': {
        'nev': 'Tóth Gábor',
        'rovid': 'A Mi Hazánk Mozgalom képviselőjeként a nemzeti érdekeket tartom szem előtt.',
        'teljes': 'Őseink földjét meg kell védenünk, a családok támogatása pedig elsődleges feladat. A Mi Hazánk Mozgalom a nemzeti érdekek és a magyar családok védelméért küzd. Bevándorlásellenes, családpárti politikát folytatunk.',
      },
      'Jobbik': {
        'nev': 'Varga István',
        'rovid': 'Jobbik - A nemzeti összefogásért, a magyar emberekért.',
        'teljes': 'A Jobbik Magyarországért Mozgalom képviselőjeként a nemzeti érdekek és a magyar családok védelméért küzdök. Programunk a gazdasági fejlődésre, a munkahelyteremtésre és a vidék támogatására épül.',
      },
      'MKKP': {
        'nev': 'Lakatos Brigitta',
        'rovid': 'MKKP - Mert a politikusoknak is szükségük van irányításra. Kutyák is élnek!',
        'teljes': 'A Magyar Kétfarkú Kutya Párt programja: szabadon, vidáman, de komolyan politizálunk. A korrupció ellen küzdünk, az állatvédelmet támogatjuk, és hiszünk abban, hogy a politika nem csak a nagy pártok játszótere kell legyen.',
      },
      'Munkáspárt': {
        'nev': 'Németh Tamás',
        'rovid': 'A Munkáspárt a dolgozókért küzd. Jobb bérek, emberi munkakörülmények.',
        'teljes': 'A Munkáspárt a magyar dolgozók érdekeit képviseli. Programunk a jobb bérek, az emberi munkakörülmények és a szociális biztonság helyreállítására irányul.',
      },
      'Független': {
        'nev': 'Kiss Erzsébet',
        'rovid': 'Független jelölt, a helyi emberekért.',
        'teljes': 'Független jelöltként állok a választók elé. Nem pártérdekek, hanem a térség fejlődése vezérel. Helyi problémákra helyi megoldásokat kínálok, pártállástól függetlenül.',
      },
    };
    
    return namesByPart[part] ?? namesByPart['Független']!;
  }

  List<Jelolt> getJeloltekByKerulet(String keruletId) {
    return _cacheJeloltek.where((j) => j.valasztokeruletId == keruletId).toList();
  }

  List<Valasztokerulet> getKeruletekByMegye(String megye) {
    return _cacheKeruletek.where((k) => k.megye == megye).toList();
  }

  List<String> get Megyek {
    return _cacheKeruletek.map((k) => k.megye).toSet().toList()..sort();
  }
}
