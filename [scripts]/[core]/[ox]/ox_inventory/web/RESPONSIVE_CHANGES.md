# Zmiany Responsywności Interfejsu ox_inventory

## Przegląd zmian

Interfejs ekwipunku został zmodyfikowany, aby był w pełni responsywny dla różnych rozdzielczości ekranu, zachowując prawidłowe proporcje i czytelność na wszystkich wspieranych rozdzielczościach.

## Wspierane rozdzielczości

### 1. **Standardowa: 1920×1080 i większe** (Base)
- Współczynnik skalowania: **1.0**
- Podstawowa rozdzielczość, dla której zaprojektowano oryginalny interfejs
- Używana również dla większych ekranów (2560×1440, 4K, itp.)

### 2. **Średnia: 1280×1024**
- Współczynnik skalowania: **0.7**
- Zmniejszone rozmiary elementów dla lepszego dopasowania
- Grid size: 8.5vh, odstępy zredukowane do 5px

### 3. **Mała: 800×600 i mniejsze**
- Współczynnik skalowania: **0.55**
- Znacznie zmniejszone rozmiary dla maksymalnego wykorzystania przestrzeni
- Grid size: 7vh, minimalne odstępy 4px
- Zachowane proporcje wszystkich komponentów

## Zmienne CSS

Wprowadzono system zmiennych CSS, które automatycznie dostosowują się do rozdzielczości:

```scss
:root {
  --scale-factor: 1;              // Globalny współczynnik skalowania
  --grid-size: 11.5vh;            // Rozmiar pojedynczego slotu
  --grid-gap: 8px;                // Odstęp między slotami
  --padding-base: 25px;           // Podstawowy padding
  --gap-base: 20px;               // Podstawowy gap
  --border-radius-base: 8px;      // Zaokrąglenie rogów
  --item-size: 7vh;               // Rozmiar ikony przedmiotu
  --hotbar-bottom: 9vh;           // Pozycja hotbara
  --notification-bottom: 20vh;    // Pozycja powiadomień
}
```

## Zakres zmian

### 1. **Komponenty Inventory**
- ✅ Grid slots - skalowanie rozmiaru i odstępów
- ✅ Inventory wrapper - responsywny padding i gap
- ✅ Slot labels - skalowane czcionki i padding
- ✅ Slot numbers - proporcjonalne rozmiary

### 2. **Tooltips**
- ✅ Szerokość i padding dostosowane do rozdzielczości
- ✅ Rozmiary czcionek przeskalowane
- ✅ Obrazy składników w odpowiednim rozmiarze

### 3. **Context Menu**
- ✅ Szerokość menu skalowana
- ✅ Padding elementów dostosowany
- ✅ Czcionki proporcjonalne

### 4. **Hotbar**
- ✅ Rozmiary slotów responsywne
- ✅ Pozycja na ekranie dostosowana
- ✅ Gap między slotami skalowany

### 5. **Notyfikacje**
- ✅ Rozmiary boxów powiadomień
- ✅ Pozycja na ekranie
- ✅ Wysokość action box

### 6. **Dialogi i kontrolki**
- ✅ Useful Controls dialog
- ✅ Inventory Control buttons
- ✅ Input fields
- ✅ Close buttons

### 7. **Pozostałe elementy**
- ✅ Weight bars
- ✅ Durability bars
- ✅ Currency icons
- ✅ Price displays
- ✅ Drag preview

## Media Queries

### Średnie małe ekrany (1280×1024)
```scss
@media screen and (max-width: 1366px) and (max-height: 1080px) {
  // Zmniejszone rozmiary o 30% (scale: 0.7)
}
```

### Bardzo małe ekrany (800×600)
```scss
@media screen and (max-width: 1024px), screen and (max-height: 768px) {
  // Zmniejszone rozmiary o 45% (scale: 0.55)
}
```

## Testowanie

Aby przetestować różne rozdzielczości:

1. **W przeglądarce:**
   - Otwórz DevTools (F12)
   - Włącz Device Toolbar (Ctrl+Shift+M)
   - Ustaw custom resolution:
     - 1920×1080 (standardowy rozmiar)
     - 2560×1440 (duży ekran - bez zmian)
     - 1280×1024 (średni mały - scale 0.7)
     - 800×600 (bardzo mały - scale 0.55)

2. **W FiveM:**
   - Zmień rozdzielczość w ustawieniach gry
   - Otwórz ekwipunek
   - Sprawdź czy wszystkie elementy są czytelne i proporcjonalne

## Uwagi techniczne

- Wszystkie rozmiary czcionek używają `calc(Xpx * var(--scale-factor))`
- Paddingi i marginesy są skalowane proporcjonalnie
- Rozmiary grid używają zmiennej `--grid-size`
- Obrazy przedmiotów skalują się z `--item-size`
- Zachowano płynność animacji i przejść

## Kompatybilność

- ✅ Chrome/Edge (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ FiveM Client (wszystkie wspierane wersje)

## Przyszłe ulepszenia

Możliwe dalsze usprawnienia:
- Dodanie support dla ekranów ultrawide (21:9)
- Opcjonalny tryb kompaktowy dla małych ekranów
- Dostosowanie dla urządzeń mobilnych (jeśli potrzebne)
- Opcja wyboru rozmiaru UI w ustawieniach

## Autor zmian

Zmiany wprowadzone: 2025-10-18
System responsywny oparty na CSS Variables i Media Queries


