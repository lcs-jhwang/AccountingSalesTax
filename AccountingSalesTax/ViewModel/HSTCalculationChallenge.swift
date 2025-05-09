//
//  HSTCalculationChallenge.swift
//  AccountingSalesTax
//
//  Created by Julien Hwang on 9/5/2025.
//

import SwiftUI

struct HSTCalculationView: View {
    @State private var salePrice = 100.0
    @State private var choices: [Double] = []
    @State private var correctAnswer = 0.0
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🧮 HST Calculation Challenge")
                .font(.title)
                .bold()

            Text("You sold a product for $\(Int(salePrice)). What is the total amount including 13% HST?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            ForEach(choices, id: \.self) { choice in
                Button(action: {
                    checkAnswer(choice)
                }) {
                    Text("$\(String(format: "%.2f", choice))")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            if showFeedback {
                Text(feedbackMessage)
                    .foregroundColor(feedbackMessage.contains("Correct") ? .green : .red)
                    .bold()
            }

            Button("🔁 Try Another") {
                generateQuestion()
            }
            .padding(.top, 30)
        }
        .padding()
        .onAppear {
            generateQuestion()
        }
    }
    
    func generateQuestion() {
        salePrice = Double([50, 100, 250, 399, 600].randomElement()!)
        correctAnswer = (salePrice * 1.13).rounded()
        let wrong1 = (salePrice * 1.3).rounded()
        let wrong2 = salePrice.rounded()
        choices = [correctAnswer, wrong1, wrong2].shuffled()
        showFeedback = false
    }
    
    func checkAnswer(_ choice: Double) {
        if choice == correctAnswer {
            feedbackMessage = "🎉 Correct! HST = \(String(format: "%.2f", salePrice * 0.13)), total = \(String(format: "%.2f", correctAnswer))"
        } else {
            feedbackMessage = "❌ Oops! Remember: HST is 13% of the price."
        }
        showFeedback = true
    }
}

#Preview {
    HSTCalculationView()
}
