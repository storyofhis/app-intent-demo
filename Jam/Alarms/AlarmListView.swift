//
//  AlarmListView.swift
//  Jam
//

import SwiftUI

struct AlarmListView: View {

    @State private var store = AlarmStore()
    @State private var editing: Alarm?
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            Group {
                if store.alarms.isEmpty {
                    ContentUnavailableView(
                        "Belum ada alarm",
                        systemImage: "alarm",
                        description: Text("Tekan + untuk menambah.")
                    )
                } else {
                    list
                }
            }
            .navigationTitle("Alarm")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tambah", systemImage: "plus") { isAdding = true }
                }
            }
            .sheet(isPresented: $isAdding) {
                AlarmEditView(alarm: Alarm(hour: 7, minute: 0)) { store.save($0) }
            }
            .sheet(item: $editing) { alarm in
                AlarmEditView(alarm: alarm) { store.save($0) }
            }
            .task { await Notifications.requestIfNeeded() }
        }
    }

    private var list: some View {
        List {
            ForEach(store.alarms) { alarm in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alarm.time)
                            .font(.system(size: 40, weight: .light, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(alarm.isEnabled ? .primary : .secondary)

                        Text(alarm.label.isEmpty
                             ? alarm.repeatSummary
                             : "\(alarm.label) · \(alarm.repeatSummary)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { alarm.isEnabled },
                        set: { store.setEnabled($0, for: alarm) }
                    ))
                    .labelsHidden()
                }
                .contentShape(.rect)
                .onTapGesture { editing = alarm }
                .swipeActions {
                    Button("Hapus", role: .destructive) { store.delete(alarm) }
                }
            }
        }
    }
}

#Preview {
    AlarmListView()
}
