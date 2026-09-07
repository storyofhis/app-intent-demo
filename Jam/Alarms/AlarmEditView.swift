//
//  AlarmEditView.swift
//  Jam
//

import SwiftUI

struct AlarmEditView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var draft: Alarm
    @State private var time: Date

    private let onSave: (Alarm) -> Void

    init(alarm: Alarm, onSave: @escaping (Alarm) -> Void) {
        _draft = State(initialValue: alarm)
        _time = State(initialValue: Self.date(hour: alarm.hour, minute: alarm.minute))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Waktu", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }

                Section("Ulangi") {
                    ForEach(Alarm.allWeekdays, id: \.self) { weekday in
                        Toggle(Self.longName(weekday), isOn: Binding(
                            get: { draft.weekdays.contains(weekday) },
                            set: { isOn in
                                if isOn {
                                    draft.weekdays.insert(weekday)
                                } else {
                                    draft.weekdays.remove(weekday)
                                }
                            }
                        ))
                    }
                }

                Section("Label") {
                    TextField("Alarm", text: $draft.label)
                }
            }
            .navigationTitle("Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        let parts = Calendar.current.dateComponents([.hour, .minute], from: time)
                        draft.hour = parts.hour ?? 0
                        draft.minute = parts.minute ?? 0
                        draft.isEnabled = true
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
    }

    private static func date(hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour, minute: minute, second: 0, of: .now
        ) ?? .now
    }

    private static func longName(_ weekday: Int) -> String {
        ["", "Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"][weekday]
    }
}

#Preview {
    AlarmEditView(alarm: Alarm(hour: 7, minute: 0)) { _ in }
}
