//
//  CircularProgressView.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let days: Int
    let timeString: String
    
    private var daysWord: String {
        daysDeclension(days)
    }
    
    private func daysDeclension(_ number: Int) -> String {
        let mod10 = number % 10
        let mod100 = number % 100
        
        if mod100 >= 11 && mod100 <= 14 {
            return "дней"
        }
        
        switch mod10 {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 14)
                .frame(width: 280, height: 280)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 0) {
                Text("\(days)")
                    .font(.custom("Onest", size: 50))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(daysWord)
                    .font(.custom("Onest", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)
                
                Text(timeString)
                    .font(.custom("Onest", size: 24))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 16)
            }
        }
    }
}
