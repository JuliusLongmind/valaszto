#!/usr/bin/env python3
"""
2026-valasztas.hu scraper - Scrapes individual candidate pages
"""

import requests
from bs4 import BeautifulSoup
import json
import time
import re
from pathlib import Path
from urllib.parse import urljoin

BASE_URL = "https://2026-valasztas.hu"

MEGYE_SLUGS = {
    "BÁCS-KISKUN": "bacs-kiskun",
    "BARANYA": "baranya",
    "BÉKÉS": "bekes",
    "BORSOD-ABAÚJ-ZEMPLÉN": "borsod-abauj-zemplen",
    "BUDAPEST": "budapest",
    "CSONGRÁD-CSANÁD": "csongnad-csanad",
    "FEJÉR": "fejer",
    "GYŐR-MOSON-SOPRON": "gyor-moson-sopron",
    "HAJDÚ-BIHAR": "hajdu-bihar",
    "HEVES": "heves",
    "JÁSZ-NAGYKUN-SZOLNOK": "jasz-nagykun-szolnok",
    "KOMÁROM-ESZTERGOM": "komarom-esztergom",
    "NÓGRÁD": "nograd",
    "PEST": "pest",
    "SOMOGY": "somogy",
    "SZABOLCS-SZATMÁR-BEREG": "szabolcs-szatmar-bereg",
    "TOLNA": "tolna",
    "VAS": "vas",
    "VESZPRÉM": "veszprem",
    "ZALA": "zala",
}

PARTOK = {
    "FIDESZ": "FIDESZ-KDNP",
    "KDNP": "FIDESZ-KDNP",
    "TISZA": "TISZA",
    "DK": "DK",
    "MI HAZÁNK": "Mi Hazánk",
    "JOBBIK": "Jobbik",
    "MKKP": "MKKP",
    "KUTYA": "MKKP",
    "MUNKÁSPÁRT": "Munkáspárt",
    "MSZP": "MSZP",
    "LMP": "LMP",
    "SZABAD": "Szabad",
    "SOL": "SOL",
    "NEM": "NEM",
}


def get_session():
    session = requests.Session()
    session.headers.update({
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "hu-HU,hu;q=0.9,en;q=0.8",
    })
    return session


def detect_party(text):
    text_upper = text.upper()
    for keyword, party in PARTOK.items():
        if keyword.upper() in text_upper:
            return party
    return "Független"


def extract_megye_from_text(text):
    for megye in MEGYE_SLUGS.keys():
        if megye in text.upper():
            return megye
    return None


def extract_oevk_from_text(text):
    match = re.search(r'(\d+)\.?\s*számú\s*OEVK?', text, re.IGNORECASE)
    if match:
        return int(match.group(1))
    return None


def scrape_candidate_page(session, url):
    try:
        response = session.get(url, timeout=15)
        if response.status_code != 200:
            return None
        
        soup = BeautifulSoup(response.text, "html.parser")
        
        name = ""
        description = ""
        kep_url = ""
        party = "Független"
        megye = None
        oevk = None
        
        h1 = soup.find("h1")
        if h1:
            name = h1.get_text(strip=True)
            party = detect_party(name)
            name = re.sub(r'\s*[-–]\s*.*(párt|jelölt).*$', '', name, flags=re.I).strip()
        
        # Get all text from the page to find megye and oevk
        all_text = soup.get_text()
        
        megye = extract_megye_from_text(all_text)
        oevk = extract_oevk_from_text(all_text)
        
        # Get description - find the main content
        ps = soup.find_all("p")
        for p in ps:
            text = p.get_text(strip=True)
            if len(text) > 50 and "bemutató oldala" not in text and "nyilvánosan" not in text:
                if len(text) > len(description):
                    description = text
        
        img = soup.find("img")
        if img:
            kep_url = img.get("src", "")
        
        return {
            "name": name,
            "description": description[:500] if description else "",
            "kep_url": kep_url,
            "party": party,
            "megye": megye,
            "oevk": oevk,
        }
        
    except Exception as e:
        return None


def get_all_candidate_urls(session):
    """Get all candidate URLs from the site"""
    candidate_urls = set()
    
    # Get from main /jeloltek/ page
    print("  Keresés a főoldalon...")
    url = f"{BASE_URL}/jeloltek/"
    response = session.get(url, timeout=15)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, "html.parser")
        for a in soup.find_all("a", href=True):
            href = str(a.get("href"))
            if "/jeloltek/" in href and href.endswith("/"):
                if href.startswith("http"):
                    candidate_urls.add(href)
                else:
                    candidate_urls.add(urljoin(BASE_URL, href))
    
    # Also try district pages
    for megye_slug, megye_nev in MEGYE_SLUGS.items():
        for oevk in range(1, 20):
            url = f"{BASE_URL}/jeloltek/{megye_slug}-{oevk:02d}/"
            response = session.get(url, timeout=10)
            if response.status_code == 200:
                soup = BeautifulSoup(response.text, "html.parser")
                for a in soup.find_all("a", href=True):
                    href = str(a.get("href"))
                    if "/jeloltek/" in href and href.endswith("/"):
                        if href.startswith("http"):
                            candidate_urls.add(href)
                        else:
                            candidate_urls.add(urljoin(BASE_URL, href))
    
    # Filter to valid URLs
    valid_urls = set()
    for url in candidate_urls:
        if "2026-valasztas.hu/jeloltek/" in url and url.count('/') >= 4:
            valid_urls.add(url)
    
    return valid_urls


def scrape_all_candidates():
    print("🚀 2026-valasztas.hu scraper...")
    
    session = get_session()
    all_candidates = []
    keruletek = []
    
    print("\n📋 Jelölt oldalak keresése...")
    candidate_links = get_all_candidate_urls(session)
    print(f"  Talált: {len(candidate_links)} jelölt link")
    
    # Scrape each candidate page
    for i, link in enumerate(sorted(candidate_links)):
        short_link = link.split("/")[-2] if "/" in link else link[-40:]
        
        if (i + 1) % 50 == 0:
            print(f"\n  [{i+1}/{len(candidate_links)}] {short_link[:30]}...")
        
        data = scrape_candidate_page(session, link)
        
        if data and data["name"] and data["megye"] and data["oevk"]:
            megye = data["megye"]
            oevk = data["oevk"]
            
            megye_slug = MEGYE_SLUGS.get(megye)
            if not megye_slug:
                continue
            
            # Find kerulet id
            kerulet_nev = f"{megye}, {oevk}. számú OEVK"
            
            # Find existing kerulet or create new
            existing_kerulet = next((k for k in keruletek if k["nev"] == kerulet_nev), None)
            if existing_kerulet:
                kerulet_id = existing_kerulet["id"]
            else:
                kerulet_id = f"{len(keruletek):03d}"
                keruletek.append({
                    "id": kerulet_id,
                    "nev": kerulet_nev,
                    "megye": megye,
                    "oevk": oevk,
                })
            
            # Count existing candidates for this kerulet
            existing_count = sum(1 for c in all_candidates if c.get("valasztokeruletNev") == kerulet_nev)
            
            candidate = {
                "id": f"{kerulet_id}_{existing_count + 1}",
                "nev": data["name"],
                "kepUrl": data["kep_url"] if data["kep_url"] else None,
                "rovidUzenet": data["description"][:140] if data["description"] else None,
                "teljesUzenet": data["description"],
                "part": data["party"],
                "valasztokeruletId": kerulet_id,
                "valasztokeruletNev": kerulet_nev,
                "sorszam": existing_count + 1,
                "verificated": "hitelesített" in (data["description"] or "").lower(),
            }
            all_candidates.append(candidate)
        
        time.sleep(0.15)
    
    # Sort keruletek
    keruletek.sort(key=lambda x: (x["megye"], x["oevk"]))
    for i, k in enumerate(keruletek):
        k["id"] = f"{i:03d}"
    
    # Update candidate kerulet IDs
    for c in all_candidates:
        for k in keruletek:
            if c["valasztokeruletNev"] == k["nev"]:
                c["valasztokeruletId"] = k["id"]
                break
    
    print(f"\n✅ Összesen: {len(keruletek)} körzet, {len(all_candidates)} jelölt")
    
    output_dir = Path(__file__).parent / "data"
    output_dir.mkdir(exist_ok=True)
    
    with open(output_dir / "jeloltek.json", "w", encoding="utf-8") as f:
        json.dump(all_candidates, f, ensure_ascii=False, indent=2)
    
    with open(output_dir / "keruletek.json", "w", encoding="utf-8") as f:
        json.dump(keruletek, f, ensure_ascii=False, indent=2)
    
    print(f"\n💾 Mentve: {output_dir / 'jeloltek.json'}")
    print(f"💾 Mentve: {output_dir / 'keruletek.json'}")
    
    return all_candidates, keruletek


if __name__ == "__main__":
    scrape_all_candidates()
