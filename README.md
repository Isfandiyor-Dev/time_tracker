# Time Tracker

Reklamasiz, offline-first soatbay ish va daromad hisoblagichi.

## Arxitektura

- `lib/domain` — frameworkdan mustaqil entity, repository va service contractlari.
- `lib/data` — Isar Community modellari/repositorysi va native timer adapteri.
- `lib/presentation` — Cubit state va Material 3 dark UI.
- `lib/core` — theme, formatter va sekund aniqligidagi hisob-kitob.

Har bir entry `hourlyRateSnapshot` va `currencySnapshot` saqlaydi. Shu sababli
loyiha tarifi keyinchalik o‘zgarsa ham tarixiy daromad o‘zgarmaydi.

## Ishga tushirish

```sh
flutter pub get
dart run build_runner build
flutter run
```

## Background timer

Android implementatsiyasi user boshlagan `specialUse` foreground service,
doimiy notification, Break/End break va Punch out actionlaridan foydalanadi.
Elapsed time monotonic tickga bog‘lanmaydi: start/break timestamp’lar saqlanadi,
shuning uchun Flutter process RAM’dan chiqarilganda ham hisob to‘g‘ri davom etadi.

iOS uchinchi tomon ilovalariga Android’dagi kabi cheksiz foreground service
bermaydi. Hozirgi buildda iOS taymeri Flutter process tirik paytda ishlaydi;
process-kill holati va lock-screen actionlari uchun Live Activities/ActivityKit
targeti alohida qo‘shilishi kerak.

A new Flutter project.
