//
//  StopwatchModel.swift
//  Jam
//
//  Waktu dihitung dari selisih dua Date, bukan dari menambah angka tiap tick.
//  Kalau ditambah per tick, dia akan meleset saat app di-background atau saat
//  frame drop. Timer di sini cuma buat menggambar, bukan buat menghitung.
//

import Foundation
import Observation

@MainActor
@Observable
final class StopwatchModel {

    struct Lap: Identifiable, Hashable {
        let id = UUID()
        let index: Int
        let split: TimeInterval    // durasi lap ini saja
        let total: TimeInterval    // total sejak start
    }

    private(set) var laps: [Lap] = []

    /// Waktu mulai periode berjalan. Nil berarti sedang berhenti.
    private var startedAt: Date?

    /// Total waktu dari periode-periode sebelumnya.
    private var accumulated: TimeInterval = 0

    private var lastLapTotal: TimeInterval = 0

    var isRunning: Bool { startedAt != nil }

    var hasStarted: Bool { isRunning || accumulated > 0 }

    func elapsed(at now: Date = .now) -> TimeInterval {
        guard let startedAt else { return accumulated }
        return accumulated + now.timeIntervalSince(startedAt)
    }

    func start() {
        guard !isRunning else { return }
        startedAt = .now
    }

    func stop() {
        guard let startedAt else { return }
        accumulated += Date.now.timeIntervalSince(startedAt)
        self.startedAt = nil
    }

    func toggle() {
        isRunning ? stop() : start()
    }

    func reset() {
        startedAt = nil
        accumulated = 0
        lastLapTotal = 0
        laps.removeAll()
    }

    func lap() {
        guard isRunning else { return }
        let total = elapsed()
        laps.insert(
            Lap(index: laps.count + 1, split: total - lastLapTotal, total: total),
            at: 0
        )
        lastLapTotal = total
    }
}
