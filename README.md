# Jam

Aplikasi jam: **Alarm, Stopwatch, Timer**. Tiga tab, SwiftUI biasa, tanpa dependensi.

Ini kode dasarnya saja — belum ada App Intents, belum ada Foundation Models.
Dibuat supaya keduanya nanti tinggal ditempel di atasnya.

```
Jam/
├── App/          JamApp, RootView (TabView)
├── Alarms/       Alarm + AlarmStore, AlarmListView, AlarmEditView
├── Stopwatch/    StopwatchModel, StopwatchView
├── Countdown/    CountdownModel, CountdownView
└── Shared/       Notifications, TimeFormat
```

769 baris. Buka `Jam.xcodeproj`, set Team, jalankan.

---

## Satu keputusan yang dipakai di semua fitur

**Waktu dihitung dari selisih dua `Date`, bukan dari angka yang ditambah tiap tick.**

```swift
// Stopwatch
accumulated + now.timeIntervalSince(startedAt)

// Timer
max(0, endsAt.timeIntervalSince(now))
```

`TimelineView` cuma bertugas menggambar ulang — bukan menghitung. Kalau angkanya
ditambah per tick, hasilnya meleset saat frame drop atau saat app masuk background,
dan makin lama makin jauh.

Efek sampingnya: timer tetap benar walau app ditutup lalu dibuka lagi, tanpa kode
tambahan.

---

## Yang sudah jalan

**Alarm** — tambah, edit, hapus, aktif/nonaktif. Ulangi per hari (Senin–Minggu) atau
sekali saja. Disimpan di `UserDefaults` lewat `Codable`. Tiap hari yang dipilih jadi
satu `UNCalendarNotificationTrigger` yang berulang.

**Stopwatch** — start, stop, lap, reset. Daftar lap dengan waktu split per lap.

**Timer** — pilih jam/menit/detik, mulai, jeda, batal. Notifikasi dijadwalkan saat
start, karena kode aplikasi tidak berjalan di background.

---

## Batasannya, supaya jujur

Ini pakai **notifikasi lokal**, dan notifikasi lokal **tidak menembus silent mode atau
Focus**. Jadi ini belum sekelas alarm bawaan iOS.

Untuk alarm yang benar-benar membangunkan orang, jalurnya **AlarmKit** (iOS 26):
butuh `NSAlarmKitUsageDescription` di Info.plist, `requestAuthorization()`, dan widget
extension kalau pakai tampilan countdown. Itu penggantian di lapisan penjadwalan saja —
`AlarmStore` dan seluruh UI tidak perlu berubah.

---

## Tempat App Intents nanti masuk

Ketiga model sudah berupa objek terpisah dari View, jadi intent bisa memanggil hal yang
sama tanpa menyentuh UI:

| Intent | Yang dipanggil |
|---|---|
| `StartStopwatchIntent` | `StopwatchModel.start()` |
| `StartTimerIntent(minutes:)` | `CountdownModel.start()` |
| `ToggleAlarmIntent(alarm:)` | `AlarmStore.setEnabled(_:for:)` |

`Alarm` juga sudah `Identifiable` + `Codable`, jadi dia calon `AppEntity` yang rapi —
`AlarmStore.alarms` langsung bisa jadi isi `allEntities()`.

Satu hal yang perlu dirapikan lebih dulu: sekarang tiap View membuat model-nya sendiri
lewat `@State`. Supaya intent dan UI berbagi state yang sama, ketiganya perlu jadi satu
sumber bersama (singleton atau `@Environment`). Itu perubahan kecil, tapi memang harus
dilakukan sebelum intent pertama ditulis.
