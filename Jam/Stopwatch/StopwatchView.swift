//
//  StopwatchView.swift
//  Jam
//

import SwiftUI

struct StopwatchView: View {

    @State private var model = StopwatchModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {

                TimelineView(.periodic(from: .now, by: 0.03)) { context in
                    Text(TimeFormat.stopwatch(model.elapsed(at: context.date)))
                        .font(.system(size: 62, weight: .light, design: .rounded))
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)

                HStack(spacing: 40) {
                    Button(model.hasStarted && !model.isRunning ? "Reset" : "Lap") {
                        if model.isRunning {
                            model.lap()
                        } else {
                            model.reset()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(!model.hasStarted)

                    Button(model.isRunning ? "Stop" : "Start") {
                        model.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(model.isRunning ? .red : .green)
                }
                .controlSize(.large)

                if model.laps.isEmpty {
                    Spacer()
                } else {
                    List(model.laps) { lap in
                        HStack {
                            Text("Lap \(lap.index)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(TimeFormat.stopwatch(lap.split))
                                .monospacedDigit()
                        }
                        .font(.callout)
                    }
                    .listStyle(.plain)
                }
            }
            .padding(.horizontal)
            .navigationTitle("Stopwatch")
        }
    }
}

#Preview {
    StopwatchView()
}
