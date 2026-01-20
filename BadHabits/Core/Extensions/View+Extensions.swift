//
//  View+Extensions.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
