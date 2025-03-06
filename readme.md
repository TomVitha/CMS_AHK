# CMS_AHK

Tento script přidává Quality of Life  funkce a vylepšení pro CMS, spíše vyloženě pro WMS.

## Požadavky

- AutoHotkey v2 - Dostupné ke stažení [zde](https://www.autohotkey.com/download/ahk-v2.exe).

## Spouštění

0. Pro fungování skriptu jsou potřeba i ostatní podpůrné složky a soubory krom hlavního skriptu CMS_AHK.ahk, který by sám o sobě nefungoval.
1. Otevři soubor `CMS_AHK.ahk` To je vše, skript nyní bude běžet na pozadí.
2. (Dobrovolné) Vlož zástupce na skript do složky po spuštění `%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` pro automatické spuštění skriptu při zapnutí počítače. 

## Funkce


- Klávesové zkratky podobné jako ve VSCode
- Vytváření elementů s třídami a ID jako pomocí Emmet Abbreviation
- Manipulace s řádky
- Automatické doplňování HTML tagů
- Automatické vypsání tagů obrázku s Úložiště


## Klávesové zkratky

### Akce editoru

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+S` | Klikne na tlačítko Uložit |
| `Esc` nebo `Ctrl+W` | Nabídne možnost uložení změn před zavřením |

### Manipulace s textem

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+V` | Nové vkládání (vloží mezi řádky) |
| `Ctrl+Shift+V` | Původní chování vkládání (přepíše existující text) |
| `Ctrl+Shift+Z` | Znovu (koresponduje `Ctrl+Y`) |

### Operace s řádky

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+Shift+D` nebo `Shift+Alt+Nahoru` | Duplikovat řádek nahoru |
| `Ctrl+D` nebo `Shift+Alt+Dolů` | Duplikovat řádek dolů |
| `Alt+Nahoru` | Posunout aktuální řádek nahoru |
| `Alt+Dolů` | Posunout aktuální řádek dolů |
| `Ctrl+Shift+K` nebo `Ctrl+Minus` | Smazat aktuální řádek |
| `Ctrl+ú` | Zmenšit odsazení řádku (koresponduje `Shift+Tab`) |
| `Ctrl+)` | Zvětšit odsazení řádku (koresponduje `Tab`) |
| `Ctrl+Backspace` | Smazat celé slovo (funguje i v jiných oknech než jen ve WMS editoru) |

### Nástroje HTML/CSS/JS

| Zkratka | Popis |
|----------|-------------|
| `Alt+W` | Vytváření elementů s třídami a ID s možností zabalení vybraného textu (jako Emmet Abbreviation) |
| `Ctrl+B` | Obalit tagy `<strong>` |
| `Ctrl+I` | Obalit tagy `<i>` |
| `Ctrl+P` | Obalit tagy `<p>` |
| `Ctrl+L` | Obalit tagy `<li>` |
| `Ctrl+G` | Vypsání tagů obrázku z Úložiště |
| `Ctrl+/` | HTML komentář |
| `Ctrl+*` | CSS komentář |
| `Ctrl+Shift+/` | JS komentář |


### Emmet Abbreviation 

`Alt+W` napodobuje Emmet Abbreviation ve VSCode a umožňuje stejnou syntaxi pro vytváření elementů s třídami a ID (vlastní atributy nejsou podporovány).

#### Syntaxe: `tag.třída#id`. 

První je vždy tag. Třídy předchází `.` tečka, každá tečka přidá další třídu. ID předchází `#` hashtag. 

Např. `button.btn.btn-yellow#open` vytvoří element `<button class="btn btn-yellow" id="open"></button>`.

Třídy i ID je možné psát v libovolném pořadí a nemusí být pospolu.

### Navigace

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+PageUp` | koresponduje `Šipka nahoru` |
| `Ctrl+PageDown` | koresponduje `Šipka dolů` |

### Jiné

| Zkratka | Popis |
|----------|-------------|
| `Ctrl+Tab` a `Ctrl+Shift+Tab` | Zabraňují přepnutí na "Editace textu" |

### Automatické doplňování HTML tagů

Skript obsahuje automatické doplňování HTML tagů:
- Napsání otevíracího tagu `<tag>` automaticky doplní uzavírací `</tag>`
- Napsání názvu tagu `tag` a zmáčknutí `Tab` automaticky doplní závorky a zavírací tag: `<tag></tag>`

### Vypsání tagů obrázku z Úložiště

V Úložišti zvol obrázek, zmáčkni kopírovat `Ctrl+C`, we WMS editoru zmáčkni `Ctrl+G` a do input boxu dej vložit `Ctrl+V`. Tagy budou automaticky vypsány včetně závorek `{{ }}` a _documentUrl_.

### Ovládání skriptu

| Zkratka | Popis |
|----------|-------------|
| `Win+PageUp` | Pozastavit skript |
| `Win+End` | Restartovat skript |

## Omezení a známé problémy


- **Víceřádkové operace**: Mnoho operací jako komentování a obalování má omezenou nebo žádnou podporu pro práci s více řádky najednou. Práce s více řádky najednou je docela bolest. Proto funkce jsou funkce jako zakomentování, či přesouvání nebo duplikování řádků omezeny na jeden řádek. (`Alt+W` však pro více řádků funguje.)
- **Schránka**: Mnoho funkcí kopírují texty a pracují se schránkou. Navzdory snahám je "zálohování" a obnovení původní schránky nekonzistentní a proto je schránka mnohdy smazána či přepsána.
- **Vkládání velkého množství textu**: Nové vkládání se s větším množstvím vkládaného textu stává nestabilním a hrozí crash CMS. Proto, při vkládání mnohořádkového textu (např. při nahrazování celého obsahu), doporučuji používat původní vkládání přes `Ctrl+Shift+V`.
- **Auto uvozovky**: Je-li kurzor na konci textu, automatické doplnění druhé uvozovky nefunguje správně.
