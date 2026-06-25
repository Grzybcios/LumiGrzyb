<div align="center">

<img src="assets/icons/lumigrzyb.png" width="160" alt="LumiGrzyb logo" />

# LumiGrzyb

**Nowoczesny kontroler oświetlenia Philips Hue dla komputerów stacjonarnych.**

Aplikacja desktopowa napisana we Flutterze, z interfejsem w stylu Fluent / WinUI 3
(rozmazane, półprzezroczyste tło Acrylic na Windows 11).

</div>

---

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
