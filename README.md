# 📻 Radiomenu

En  FiveM radio animation menu med forskellige radio animationer. Nemt konfigurerbar og brugervenlig.

## ✨ Features

- **forskellige radio animationer** - Vælg mellem et bredt udvalg af professionelle radio animationer
- **Brugervenlig menu** - Intuitiv ox_lib menu interface
- **Konfigurerbar** - Nem at tilpasse i `config.lua`
- **Automatisk gem funktion** - Husker din foretrukne animation mellem sessions
- **Optimeret performance** - Minimal ressourceforbrug
- **Plug and play** - Nem installation og opsætning

## 📋 Krav

- [ox_lib](https://github.com/overextended/ox_lib)
- [pma-voice](https://github.com/AvarianKnight/pma-voice)
- [Mani-Radio](https://discord.gg/qd882rDMyB)

## 🎨 Valgfrit - Premium Radio Animationer

Ressourcen kommer med 4 standard radio animationer, men du kan udvide med professionelle premium animationer fra Pazeee:
- **Køb radio animationer**: [Pazeee's Tebex Shop](https://pazeee.tebex.io/category/newemotes)
- Disse giver dig adgang til yderligere 6+ unikke og høj-kvalitets radio animationer

## 🚀 Installation

1. Download ressourcen og placer den i din `resources` mappe
2. Sørg for at `ox_lib`, `pma-voice` og `Mani-Radio` er installeret
3. Tilføj følgende til din `server.cfg`:
```cfg
ensure ox_lib
ensure pma-voice
ensure mani_radio
ensure Radiomenu
```
4. Genstart serveren

## 🎮 Brug

Åbn radio menu'en ved at trykke på den konfigurerede tast eller kommando (standard afhænger af din pma-voice opsætning).

### Kommandoer
- Åbn menuen for at vælge din foretrukne radio animation
- Animationen vil automatisk blive gemt og husket til næste gang

## ⚙️ Konfiguration

Du kan nemt tilpasse animationerne i `config.lua`. Hver animation har følgende indstillinger:

```lua
{
    label = "Radio Animation 1",
    description = "Radio animation 1",
    dict = "random@arrests",
    anim = "generic_radio_chatter",
    boneIndex = 18905,
    offset = {x = 0.13555, y = 0.04555, z = -0.0120},
    rotation = {x = 130.0, y = -38.0, z = 170.0},
    useProp = true
}
```

### Tilføj dine egne animationer
1. Åbn `config.lua`
2. Tilføj en ny animation til `Config.RadioAnimations` tabellen
3. Genstart ressourcen

## 📦 Struktur

```
Radiomenu/
├── client/
│   └── main.lua          # Client-side logik
├── server/
│   └── main.lua          # Server-side logik
├── stream/               # Animation filer
│   └── pazeee@radio*.ycd # Radio animationer
├── config.lua            # Konfigurationsfil
├── fxmanifest.lua        # Manifest
└── README.md             # Denne fil
```

## 🎨 Credits

- **Udvikler**: [Faws-Development](https://github.com/MrFawsDK)
- **Radio Animationer**: [Pazeee](https://github.com/pazeee) - Stor tak for de fantastiske radio animationer!
- **ox_lib**: [Overextended](https://github.com/overextended)
- **pma-voice**: [AvarianKnight](https://github.com/AvarianKnight)

## 📝 Version

**Nuværende version**: 2.0.0

## 🐛 Support

Hvis du oplever problemer eller har forslag til forbedringer, er du velkommen til at oprette et issue på GitHub.

## 📜 Licens

Dette projekt er open source. Du er velkommen til at bruge og modificere det til din egen server.

---

**Udviklet med ❤️ af Fawsdev**