//
//  RootView.swift
//  Jam
//
//  Created by Maula Izza Azizi on 07/09/26.
//


import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Alarm", systemImage: "alarm") {
                AlarmListView()
            }
            Tab("Stopwatch", systemImage: "stopwatch") {
                StopwatchView()
            }
            Tab("Timer", systemImage: "timer") {
                CountdownView()
            }
        }
    }
}

#Preview {
    RootView()
}
