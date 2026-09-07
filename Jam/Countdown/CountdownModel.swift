//
//  CountdownModel.swift
//  Jam
//
//  Created by Maula Izza Azizi on 07/09/26.
//

import AudioToolbox
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
    /// Suara dibunyikan langsung di sini, bukan lewat notifikasi — supaya
    /// kedengaran walau app lagi dibuka dan ditatap (notifikasi tidak
    /// bersuara saat app foreground kecuali app-nya di-background dulu).
    func finishIfNeeded(at now: Date) {
        guard isRunning, let endsAt, now >= endsAt else { return }
        isRunning = false
        pausedRemaining = 0
        self.endsAt = nil
        AudioServicesPlaySystemSound(1005)
    }
}
