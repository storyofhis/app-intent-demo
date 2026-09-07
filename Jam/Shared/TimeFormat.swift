//
//  TimeFormat.swift
//  Jam
//

import Foundation

enum TimeFormat {

    /// 00:00.00 — dan berubah jadi 1:02:03.45 kalau lewat satu jam.
    static func stopwatch(_ interval: TimeInterval) -> String {
        let total = max(0, interval)
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        let seconds = Int(total) % 60
        let hundredths = Int((total - floor(total)) * 100)

        if hours > 0 {
            return String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, hundredths)
        }
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }

    /// 00:00:00 — dibulatkan ke atas supaya angkanya tidak lompat ke 0 lebih awal.
    static func countdown(_ interval: TimeInterval) -> String {
        let total = Int(ceil(max(0, interval)))
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }

    static func clock(hour: Int, minute: Int) -> String {
        String(format: "%02d.%02d", hour, minute)
    }
}
