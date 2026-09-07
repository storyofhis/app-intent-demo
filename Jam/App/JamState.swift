//
//  JamState.swift
//  Jam
//
//  Created by Maula Izza Azizi on 07/09/26.
//

import Foundation
import Observation

enum JamTab: String, Hashable {
    case alarm, stopwatch, timer
}


@MainActor
@Observable
final class Navigation {
    var tab: JamTab = .alarm
}

@MainActor
enum JamState {
    static let countdown = CountdownModel()
    static let navigation = Navigation()
}
