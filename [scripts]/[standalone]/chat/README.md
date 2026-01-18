# Chat System dla FiveM

Zaawansowany system czatu dla FiveM z wieloma funkcjami bezpieczeństwa i optymalizacji.

## ✨ Funkcje

- ✅ Walidacja i sanityzacja wiadomości
- ✅ Zabezpieczenie przed spamem
- ✅ Wskaźnik pisania nad graczami
- ✅ Wsparcie dla komend
- ✅ Sugestie komend
- ✅ Historia wiadomości (strzałki góra/dół)
- ✅ Przewijanie czatu (Page Up/Down)
- ✅ Auto-complete (Tab)
- ✅ Responsywny design
- ✅ Obsługa błędów
- ✅ Eksporty dla innych zasobów

## 📦 Zależności

- `es_extended` (opcjonalne)
- `ox_lib`
- `oxmysql` (opcjonalne)

## ⚙️ Konfiguracja

Edytuj plik `config.lua` aby dostosować ustawienia:

```lua
Config.MaxMessageLength = 256          -- Maksymalna długość wiadomości
Config.EnableAntiSpam = true           -- Włącz zabezpieczenie przed spamem
Config.SpamCooldown = 1000             -- Cooldown między wiadomościami (ms)
Config.MaxMessagesPerMinute = 10       -- Limit wiadomości na minutę
Config.EnableTypingIndicator = true    -- Wskaźnik pisania
Config.HideAdminTyping = true          -- Ukryj wskaźnik pisania dla adminów
Config.TypingIndicatorDistance = 15.0  -- Dystans renderowania wskaźnika
```

## 🔧 API / Eksporty

### Client-side

```lua
-- Dodaj wiadomość do czatu
exports['chat']:addMessage({
    color = {255, 255, 255},
    multiline = true,
    args = {'Tytuł', 'Treść wiadomości'}
})

-- Dodaj sugestię komendy
exports['chat']:addSuggestion('/przykład', 'Opis komendy', {
    {name = 'parametr1', help = 'Opis parametru'},
    {name = 'parametr2', help = 'Opis parametru'}
})

-- Usuń sugestię
exports['chat']:removeSuggestion('/przykład')

-- Wyczyść czat
exports['chat']:clearChat()

-- Sprawdź czy czat jest otwarty
local isOpen = exports['chat']:isChatOpen()

-- Przełącz widoczność czatu
exports['chat']:toggleChat(true) -- true = ukryj, false = pokaż
```

### Server-side

```lua
-- Wyślij wiadomość do gracza
exports['chat']:sendMessage(source, 'Server', 'Wiadomość dla gracza', {255, 0, 0})

-- Wyślij wiadomość do wszystkich
exports['chat']:sendMessageToAll('Server', 'Wiadomość globalna', {0, 255, 0})

-- Wyczyść czat dla gracza
exports['chat']:clearChat(source)

-- Wyczyść czat dla wszystkich
exports['chat']:clearChatForAll()
```

## 🎨 Customizacja UI

### Pozycja i rozmiar

Edytuj `config.lua`:

```lua
Config.ChatPosition = {
    top = 15,   -- Odległość od góry
    left = 15   -- Odległość od lewej
}
Config.ChatWidth = 520
Config.ChatHeight = 200
```

### Style CSS

Edytuj `html/index.css` aby zmienić wygląd czatu.

### Szablony wiadomości

Edytuj `html/config.default.js` aby dostosować szablony:

```javascript
templates: {
    default: '<div>Twój szablon HTML</div>',
    // Dodaj więcej szablonów...
}
```

## 🎮 Klawisze

- **T** - Otwórz czat
- **ESC** - Zamknij czat
- **Enter** - Wyślij wiadomość
- **↑ / ↓** - Historia wiadomości
- **Page Up / Down** - Przewijanie czatu
- **Tab** - Auto-complete komend

## 👤 Funkcja ukrywania wskaźnika pisania dla adminów

System pozwala na ukrycie wskaźnika pisania nad głową adminów. Jest to przydatne gdy admini chcą pisać w trybie "niewidzialnym".

### Jak to działa:
1. Ustaw `Config.HideAdminTyping = true` w pliku `config.lua`
2. System automatycznie wykryje adminów przez ESX:
   - Jeśli gracz **NIE** ma grupy `user`, to jest traktowany jako admin
   - Działa dla grup: `admin`, `superadmin`, `mod`, etc.
3. Gdy admin pisze, inni gracze **nie zobaczą** wskaźnika pisania nad jego głową

### Przykład grup ESX:
- `user` - zwykły gracz (POKAZUJE wskaźnik pisania)
- `admin` - administrator (UKRYWA wskaźnik pisania)
- `superadmin` - super administrator (UKRYWA wskaźnik pisania)
- `mod` - moderator (UKRYWA wskaźnik pisania)

## 🔒 Bezpieczeństwo

System zawiera:
- Walidację długości wiadomości
- Sanityzację znaków specjalnych
- Zabezpieczenie przed spamem
- Limity wiadomości na minutę
- Filtrowanie zabronionych słów (opcjonalne)


## 📝 Przykłady użycia

### Wysłanie kolorowej wiadomości

```lua
-- Client
TriggerEvent('chat:addMessage', {
    color = {255, 0, 0},
    multiline = true,
    args = {'^1ERROR', 'Coś poszło nie tak!'}
})

-- Server
TriggerClientEvent('chat:addMessage', source, {
    color = {0, 255, 0},
    multiline = true,
    args = {'^2SUCCESS', 'Operacja zakończona sukcesem!'}
})
```

### Formatowanie tekstu

- `^0` - ^9 - Kolory (zdefiniowane w CSS)
- `^*tekst^r` - **Pogrubienie**
- `^_tekst^r` - <u>Podkreślenie</u>
- `^~tekst^r` - ~~Przekreślenie~~

### Dodanie komendy z sugestiami

```lua
RegisterCommand('heal', function(source, args)
    -- Twój kod
end)

-- Dodaj sugestię
TriggerEvent('chat:addSuggestion', '/heal', 'Wylecz gracza', {
    {name = 'id', help = 'ID gracza'},
    {name = 'hp', help = 'Ilość HP (opcjonalne)'}
})
```

## 📜 Changelog

### Version 1.1.0
- ✅ Dodano walidację i sanityzację wiadomości
- ✅ Dodano zabezpieczenie przed spamem
- ✅ Zoptymalizowano wskaźnik pisania
- ✅ Dodano obsługę błędów
- ✅ Dodano eksporty dla innych zasobów
- ✅ Naprawiono problem z cache i ESX
- ✅ Poprawiono operatory porównania w JavaScript
- ✅ Dodano plik konfiguracyjny

## 📞 Wsparcie

W razie problemów:
1. Sprawdź konsolę F8 i konsolę serwera
2. Upewnij się że wszystkie zależności są zainstalowane
3. Zrestartuj zasób: `restart chat`

## 📄 Licencja

Autorzy: QF Developers

---

**Enjoy! 🎉**

