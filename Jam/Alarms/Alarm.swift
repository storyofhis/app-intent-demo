//
//  Alarm.swift
//  Jam
//

import Foundation
import Observation

struct Alarm: Identifiable, Codable, Hashable {
    var id = UUID()
    var hour: Int
    var minute: Int
    var label: String = ""
    /// Konvensi Calendar: 1 = Minggu … 7 = Sabtu. Kosong berarti sekali saja.
    var weekdays: Set<Int> = []
    var isEnabled: Bool = true

    var time: String { TimeFormat.clock(hour: hour, minute: minute) }

    var repeatSummary: String {
        if weekdays.isEmpty { return "Sekali" }
        if weekdays.count == 7 { return "Setiap hari" }
        if weekdays == [2, 3, 4, 5, 6] { return "Hari kerja" }
        if weekdays == [1, 7] { return "Akhir pekan" }
        return weekdays.sorted().map(Alarm.shortName).joined(separator: " ")
    }

    static func shortName(_ weekday: Int) -> String {
        ["", "Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"][weekday]
    }

    static let allWeekdays = Array(1...7)
}

@MainActor
@Observable
final class AlarmStore {

    private(set) var alarms: [Alarm] = []

    private let key = "jam.alarms"

    init() {
        load()
    }

    func save(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
        } else {
            alarms.append(alarm)
        }
        alarms.sort { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
        persist()
        Task { await Notifications.scheduleAlarm(alarm) }
    }

    func delete(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        persist()
        Notifications.cancel(prefix: alarm.id.uuidString)
    }

    func setEnabled(_ isEnabled: Bool, for alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index].isEnabled = isEnabled
        persist()

        let updated = alarms[index]
        Task { await Notifications.scheduleAlarm(updated) }
    }

    // MARK: Penyimpanan

    private func persist() {
        guard let data = try? JSONEncoder().encode(alarms) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([Alarm].self, from: data)
        else { return }
        alarms = saved
    }
}
