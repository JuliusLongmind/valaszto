import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../models/jelolt.dart';
import '../models/valasztokerulet.dart';

class ValasztasScraper {
  static const String _baseUrl = 'https://2026-valasztas.hu';
  
  final http.Client _client;
  
  ValasztasScraper({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Valasztokerulet>> fetchKeruletek() async {
    final List<Valasztokerulet> keruletek = [];
    
    final megyek = [
      'BÁCS-KISKUN', 'BARANYA', 'BÉKÉS', 'BORSOD-ABAÚJ-ZEMPLÉN',
      'BUDAPEST', 'CSONGRÁD-CSANÁD', 'FEJÉR', 'GYŐR-MOSON-SOPRON',
      'HAJDÚ-BIHAR', 'HEVES', 'JÁSZ-NAGYKUN-SZOLNOK', 'KOMÁROM-ESZTERGOM',
      'NÓGRÁD', 'PEST', 'SOMOGY', 'SZABOLCS-SZATMÁR-BEREG',
      'TOLNA', 'VAS', 'VESZPRÉM', 'ZALA'
    ];

    int index = 0;
    for (final megye in megyek) {
      final response = await _client.get(
        Uri.parse('$_baseUrl/jeloltek/${megye.toLowerCase().replaceAll('Á', 'a').replaceAll('É', 'e')}-01/'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        
        final links = document.querySelectorAll('a[href*="/jeloltek/"]');
        int maxOevk = 0;
        
        for (final link in links) {
          final href = link.attributes['href'] ?? '';
          final match = RegExp(r'/jeloltek/[\w-]+-0*(\d+)/').firstMatch(href);
          if (match != null) {
            final oevk = int.tryParse(match.group(1) ?? '') ?? 0;
            if (oevk > maxOevk) maxOevk = oevk;
          }
        }

        for (int oevk = 1; oevk <= maxOevk; oevk++) {
          keruletek.add(Valasztokerulet(
            id: index.toString().padLeft(2, '0'),
            nev: '$megye, $oevk. számú OEVK',
            megye: megye,
            oevk: oevk,
          ));
          index++;
        }
      }
    }

    return keruletek;
  }

  Future<List<Jelolt>> fetchJeloltekByKerulet(Valasztokerulet kerulet) async {
    final List<Jelolt> jeloltek = [];
    
    final urlMegye = kerulet.megye.toLowerCase()
        .replaceAll('Á', 'a')
        .replaceAll('É', 'e')
        .replaceAll('Ő', 'o')
        .replaceAll('Ű', 'u');
    
    final url = '$_baseUrl/jeloltek/$urlMegye-${kerulet.oevk.toString().padLeft(2, '0')}/';
    
    try {
      final response = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        
        final articles = document.querySelectorAll('article, .candidate-card, .jelolt');
        
        int sorszam = 1;
        for (final article in articles) {
          final nameEl = article.querySelector('h2, h3, .nev, [class*="name"]');
          final descEl = article.querySelector('p, .leiras, .description, [class*="desc"]');
          final imgEl = article.querySelector('img');
          
          final name = nameEl?.text?.trim() ?? '';
          if (name.isEmpty) continue;
          
          final description = descEl?.text?.trim() ?? '';
          final imgUrl = imgEl?.attributes['src'];
          
          String part = 'Független';
          final partEl = article.querySelector('[class*="part"], .párt, .party');
          if (partEl != null) {
            part = partEl.text?.trim() ?? 'Független';
          }
          
          jeloltek.add(Jelolt(
            id: '${kerulet.id}_$sorszam',
            nev: name,
            kepUrl: imgUrl,
            rovidUzenet: description.length > 140 ? '${description.substring(0, 140)}...' : description,
            teljesUzenet: description,
            part: part,
            valasztokeruletId: kerulet.id,
            valasztokeruletNev: kerulet.nev,
            sorszam: sorszam,
            verificated: description.isNotEmpty,
          ));
          
          sorszam++;
        }
      }
    } catch (e) {
      // Return empty list on error
    }
    
    return jeloltek;
  }

  void dispose() {
    _client.close();
  }
}
