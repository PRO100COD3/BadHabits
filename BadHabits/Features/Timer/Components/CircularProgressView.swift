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
                .animation(.linear(duration: 0.3), value: progress)
            
            VStack(spacing: 0) {
                Text("\(days)")
                    .font(.custom("Onest", size: 50))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("дней")
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
