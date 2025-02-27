# CMS_AHK

Tento script přidává Quality of Life  funkce a vylepšení pro CMS, spíše vyloženě pro WMS.

## Požadavky

- AutoHotkey v2 - Dostupné ke stažení [zde](https://www.autohotkey.com/download/ahk-v2.exe).

## Spouštění

0. Pro fungování skriptu jsou potřeba i ostatní podpůrné složky soubory krom hlavního skriptu CMS_AHK.ahk, který by sám o sobě nefungoval.
1. Otevři soubor `CMS_AHK.ahk`
2. (Dobrovolné) Vlož zástupce na skript do složky po spuštění `%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` pro automatické spuštění skriptu při zapnutí počítače 

## Funkce


- Klávesové zkratky podobné jako ve VSCode
- Vytváření elementů s třídami a ID jako pomocí Emmet Abbreviation
- Manipulace s řádky
- Automatické doplňování HTML tagů


## Klávesové zkratky

### Akce dokumentu

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+S` | Klikne na tlačítko Uložit |
| `Esc` nebo `Ctrl+W` | Nabídne možnost uložení změn před zavřením |

### Manipulace s textem

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+V` | Nové vkládání (vloží mezi řádky) |
| `Ctrl+Shift+V` | Původní chování vkládání (přepíše existující text) |
| `Ctrl+Shift+Z` | Znovu (napodobuje `Ctrl+Y`) |
| `Shift+ů` (uvozovka) | Obalí vybraný text uvozovkami |

### Operace s řádky

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+D` nebo `Shift+Alt+Dolů` | Duplikovat řádek dolů |
| `Ctrl+Shift+D` nebo `Shift+Alt+Nahoru` | Duplikovat řádek nahoru |
| `Alt+Nahoru` | Posunout aktuální řádek nahoru |
| `Alt+Dolů` | Posunout aktuální řádek dolů |
| `Ctrl+Shift+K` nebo `Ctrl+-` | Smazat aktuální řádek |
| `Ctrl+ú` | Zmenšit odsazení řádku (Napodobuje `Shift+Tab`) |
| `Ctrl+)` | Zvětšit odsazení řádku (Napodobuje `Tab`) |
| `Ctrl+Backspace` | Smazat celé slovo (funguje i v jiných oknech než jen ve WMS editoru) |

### Nástroje HTML/CSS

| Zkratka | Popis |
|----------|-------------|
| `Alt+W` | Vytváření elementů s třídami a ID s možností zabalení vybraného textu (jako Emmet Abbreviation) |
| `Ctrl+B` | Obalit tagy `<strong>` |
| `Ctrl+I` | Obalit tagy `<i>` |
| `Ctrl+P` | Obalit tagy `<p>` |
| `Ctrl+L` | Obalit tagy `<li>` |
| `Ctrl+/` | Vložit HTML komentář |
| `Ctrl+*` | Vložit CSS komentář |


### Emmet Abbreviation 

`Alt+W` napodobuje Emmet Abbreviation ve VSCode a umožňuje stejnou syntaxi pro vytváření elementů s třídami a ID (vlastní atributy nejsou podporovány).

#### Syntaxe: `tag.třída#id`. 

První je vždy tag. Třídu předchází `.` tečka , každá tečka přidá další třídu. ID předchází `#` hashtag. Třídy a ID je možné psát v libovolném pořadí a nemusí být pospolu.

Např `button.btn.btn-yellow#open` vytvoří element `<button class="btn btn-yellow" id="open"></button>`.


### Navigace

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+PageUp` | Šipka nahoru |
| `Ctrl+PageDown` | Šipka dolů |

### Jiné

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+Tab` a `Ctrl+Shift+Tab` | Zabraňují přepnutí na "Editace textu" |

### Automatické doplňování HTML tagů

Skript obsahuje automatické doplňování HTML tagů:
- Napsání otevíracího tagu `<tag>` automaticky doplní uzavírací `</tag>`
- Napsání názvu tagu `tag` automaticky doplní závorky a zavírací tag: `<tag></tag>`

### Ovládání skriptu

| Zkratka | Popis |
|----------|-------------|
| `Win+PageUp` | Pozastavit skript |
| `Win+End` | Restartovat skript |

## Omezení a známé problémy

Skript má několik omezení, kterých byste si měli být vědomi:

- **Víceřádkové operace**: Mnoho operací jako komentování a obalování má omezenou nebo žádnou podporu pro víceřádkové výběry textu. Práce s více řádky najednou je docela bolest. Proto funkce jsou funkce jako zakomentování, či přesouvání nebo duplikování řádků omezeny na jeden řádek. (`Alt+W` však pro více řádků funguje.)
- **Schránka**: Mnoho funkcí kopírují texty a pracují se schránkou. Navzdory snaze je "zálohování" a obnovení původní schránky nekonzistentní a proto je schránka mnohdy smazána či přepsána.
- **Vkládání velkého množství textu**: Nové vkládání se s větším množstvím vkládaného textu stává nestabilním a hrozí crash CMS. Proto, při vkládání velkého množství (např. při nahrazování celého obsahu), doporučuji používat původní vkládání přes `Ctrl+Shift+V`
- **Auto uvozovky**: Je-li kurzor na konci textu, automatické doplnění druhé uvozovky nefunguje správně.
