//
//  CountdownModel.swift
//  Jam
//
//  Sama seperti stopwatch: yang disimpan adalah tanggal selesai, bukan angka
//  yang dikurangi tiap detik. Jadi kalau app ditutup lalu dibuka lagi, sisa
//  waktunya tetap benar.
//
//  Notifikasi dijadwalkan saat start, karena kode tidak jalan di background.
//

import Foundation
import Observation

@MainActor
@Observable
final class CountdownModel {

    var hours = 0
    var minutes = 5
    var seconds = 0
    var label = ""

    private(set) var isRunning = false

    /// Kapan seharusnya selesai. Nil kalau belum jalan.
    private var endsAt: Date?

    /// Sisa waktu saat dipause.
    private var pausedRemaining: TimeInterval?

    private let notificationID = "jam.countdown"

    var configuredDuration: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }

    var isActive: Bool { endsAt != nil || pausedRemaining != nil }

    func remaining(at now: Date = .now) -> TimeInterval {
        if let pausedRemaining { return pausedRemaining }
        guard let endsAt else { return configuredDuration }
        return max(0, endsAt.timeIntervalSince(now))
    }

    var isFinished: Bool {
        isActive && !isRunning && remaining() <= 0
    }

    func start() {
        let duration = pausedRemaining ?? configuredDuration
        guard duration > 0 else { return }

        endsAt = Date.now.addingTimeInterval(duration)
        pausedRemaining = nil
        isRunning = true

        let id = notificationID
        let text = label
        Task { await Notifications.scheduleCountdown(id: id, after: duration, label: text) }
    }

    func pause() {
        guard isRunning else { return }
        pausedRemaining = remaining()
        endsAt = nil
        isRunning = false
        Notifications.cancel(id: notificationID)
    }

    func cancel() {
        endsAt = nil
        pausedRemaining = nil
        isRunning = false
        Notifications.cancel(id: notificationID)
    }

    /// Dipanggil oleh view saat sisa waktu menyentuh nol.
    func finishIfNeeded(at now: Date) {
        guard isRunning, let endsAt, now >= endsAt else { return }
        isRunning = false
        pausedRemaining = 0
        self.endsAt = nil
    }
}
