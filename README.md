<div align="center">
    
# LumiGrzyb

**Nowoczesny kontroler oświetlenia Philips Hue dla komputerów stacjonarnych.**

Aplikacja desktopowa napisana we Flutterze, z interfejsem w stylu Fluent / WinUI 3
(rozmazane, półprzezroczyste tło Acrylic na Windows 11).

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter&logoColor=white)

</div>

---

## 🤔 Po co to powstało? (Why?)

Oficjalna aplikacja Philips Hue jest **tylko na telefon** — żeby zmienić światło przy
biurku, trzeba sięgać po komórkę, odblokować ją i czekać na załadowanie apki. Kiedy
pracujesz lub grasz na komputerze, to niepotrzebne tarcie.

**LumiGrzyb** rozwiązuje to, czego brakuje w ekosystemie Hue na desktopie:

- 🖥️ **Sterowanie z poziomu komputera** — bez sięgania po telefon, wszystko pod ręką.
- ⚡ **Natychmiastowa reakcja** — suwaki działają od razu (optymistyczny UI), bez
  irytującego opóźnienia widocznego w oficjalnej apce.
- 🪟 **Natywny wygląd Windows 11** — efekt Acrylic / Fluent zamiast przeniesionego
  interfejsu mobilnego.
- 🔓 **Bez konta i bez chmury** — łączy się bezpośrednio z mostkiem w sieci lokalnej;
  działa nawet bez dostępu do internetu (lokalne wykrywanie mostka).
- 🎉 **Tryb „Impreza"** — dynamiczna animacja kolorów, której oficjalna apka nie ma w
  tak prostej formie.
- 🪶 **Lekka i szybka** — jedno małe okno, zero zbędnych dodatków.

To projekt hobbystyczny — zbudowany dla wygody i nauki, nie jako zamiennik pełnej
funkcjonalności (sceny, automatyzacje, harmonogramy) oficjalnej aplikacji.

## ✨ Funkcje

- 🔍 **Automatyczne wykrywanie** mostka Philips Hue w sieci lokalnej
- 🔗 **Parowanie** z mostkiem (przycisk link) i zapamiętywanie klucza API
- 💡 **Sterowanie lampami** — włączanie/wyłączanie, jasność, temperatura barwowa, kolor
- 🎨 **Wybór kola** — dialog z kołem barw, suwakiem jasności i gotowymi presetami
- 🎛️ **Sterowanie grupowe** — wszystkie lampy naraz + wspólna jasność
- 🎉 **Tryb „Impreza"** — dynamiczna animacja kolorów
- 🪟 **Tło Acrylic (WinUI 3)** — rozmazane, półprzezroczyste tło na Windows 11
- ♻️ **Optymistyczny UI** — suwaki reagują natychmiast, bez czekania na mostek

## 🖥️ Wymagania

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.3 lub nowszy
- Windows 10/11 (zalecane Windows 11 dla pełnego efektu Acrylic)
- Mostek Philips Hue w tej samej sieci lokalnej

## 🚀 Uruchomienie (tryb deweloperski)

```bash
flutter pub get
flutter run -d windows
```

## 📦 Budowanie wersji produkcyjnej

```bash
flutter build windows --release
```

Gotowa aplikacja znajdzie się w `build/windows/x64/runner/Release/`.

## 🛠️ Tworzenie instalatora (Windows)

Instalator `.exe` budowany jest przy pomocy [Inno Setup](https://jrsoftware.org/isinfo.php).

```bash
# Jednorazowo zainstaluj Inno Setup, np.:
scoop install inno-setup        # lub: winget install JRSoftware.InnoSetup

# Zbuduj release + instalator jednym poleceniem:
cd installer
./build_installer.ps1
```

Gotowy plik `LumiGrzyb-Setup-<wersja>.exe` pojawi się w `installer/Output/`.

## 🎨 Zmiana ikony / logo

Logo to `assets/icons/lumigrzyb.png`. Po jego podmianie wygeneruj ikony aplikacji:

```bash
dart run flutter_launcher_icons
```

## 📁 Struktura projektu

```
lib/
├── main.dart                 # Punkt wejścia + inicjalizacja tła Acrylic
├── controllers/
│   └── hue_app_controller.dart   # Logika aplikacji (stan, debounce, odświeżanie)
├── models/
│   ├── app_config.dart           # Konfiguracja (IP, klucz API)
│   └── hue_light.dart            # Model lampy i jej stanu
├── screens/
│   └── home_screen.dart          # Główny ekran
├── services/
│   ├── hue_bridge.dart           # Komunikacja HTTP z mostkiem Hue
│   ├── config_service.dart       # Zapis/odczyt konfiguracji
│   ├── color_utils.dart          # Konwersje kolorów (HSV ↔ Hue)
│   └── animation_engine.dart     # Animacja trybu „Impreza"
├── theme/
│   ├── app_colors.dart           # Paleta barw (Fluent / WinUI 3)
│   └── app_theme.dart            # Motyw aplikacji
└── widgets/
    ├── surface_card.dart         # Karta „szklana" (Acrylic)
    ├── app_button.dart           # Przycisk z efektem hover
    ├── connection_panel.dart     # Panel połączenia/parowania
    ├── group_controls.dart       # Sterowanie grupowe
    ├── light_card.dart           # Karta pojedynczej lampy
    └── color_picker_dialog.dart  # Dialog wyboru koloru

installer/                        # Skrypty instalatora Inno Setup
windows/ · linux/ · macos/ · web/ # Pliki platformowe Fluttera
```

## ⚙️ Konfiguracja

Klucz API mostka zapisywany jest lokalnie w pliku `config.json`
w katalogu danych użytkownika (`%APPDATA%\LumiGrzyb\` na Windows).
Plik ten **nie jest** dodawany do repozytorium (zawiera dane prywatne).

---

<div align="center">
Made with 🍄 by Grzyb
</div>
