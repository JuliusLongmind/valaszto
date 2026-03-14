# F-Droid Submit

## Opció 1: Saját F-Droid repo létrehozása

1. Töltsd le az F-Droid app-ot
2. Válaszd: "Repo hozzáadása" 
3. Add meg ezt a URL-t: (amikor publikálod)

## Opció 2: F-Droid-ba felvétel

### Gyorsabb: Saját repo
1. Uploadold ezt a mappát egy git repository-ba (GitHub/GitLab)
2. Az F-Droid app-ban add hozzá a repo URL-t

### Hivatalos F-Droid
1. Forkold: https://gitlab.com/fdroid/fdroiddata
2. Adj hozzá egy `hu.walle.valaszto.yml` fájlt a `metadata/` mappába
3. Nyiss pull requestet

## Frissítés
A `hu.walle.valaszto.yml` fájlt frissítsd új verzióknál:
- versionName: "x.x.x"
- versionCode: x
- Build/ábrazítés APK-t

## APK
Az aktuális APK: `app-release.apk` (46MB)
