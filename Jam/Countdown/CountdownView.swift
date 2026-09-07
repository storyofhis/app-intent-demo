//
//  CountdownView.swift
//  Jam
//

import SwiftUI

struct CountdownView: View {

    @State private var model = CountdownModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {

                if model.isActive {
                    running
                } else {
                    picker
                }

                controls
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Timer")
            .task { await Notifications.requestIfNeeded() }
        }
    }

    private var picker: some View {
        HStack(spacing: 0) {
            wheel("jam", value: $model.hours, range: 0..<24)
            wheel("menit", value: $model.minutes, range: 0..<60)
            wheel("detik", value: $model.seconds, range: 0..<60)
        }
        .frame(height: 180)
        .padding(.top, 16)
    }

    private func wheel(_ unit: String, value: Binding<Int>, range: Range<Int>) -> some View {
        Picker(unit, selection: value) {
            ForEach(range, id: \.self) { number in
                Text("\(number) \(unit)").tag(number)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var running: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { context in
            VStack(spacing: 10) {
                Text(TimeFormat.countdown(model.remaining(at: context.date)))
                    .font(.system(size: 62, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(model.isFinished ? .red : .primary)

                if model.isFinished {
                    Text("Selesai")
                        .font(.headline)
                        .foregroundStyle(.red)
                } else if !model.label.isEmpty {
                    Text(model.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: context.date) { _, now in
                model.finishIfNeeded(at: now)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var controls: some View {
        VStack(spacing: 16) {
            if !model.isActive {
                TextField("Label (opsional)", text: $model.label)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 40) {
                Button("Batal") { model.cancel() }
                    .buttonStyle(.bordered)
                    .disabled(!model.isActive)

                Button(model.isRunning ? "Jeda" : "Mulai") {
                    model.isRunning ? model.pause() : model.start()
                }
                .buttonStyle(.borderedProminent)
                .tint(model.isRunning ? .orange : .green)
                .disabled(!model.isRunning && model.remaining() <= 0)
            }
            .controlSize(.large)
        }
    }
}

#Preview {
    CountdownView()
}
