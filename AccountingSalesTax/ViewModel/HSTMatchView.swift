//
//  HSTPayableVsRecoverableDrag&Drop.swift
//  AccountingSalesTax
//
//  Created by Julien Hwang on 9/5/2025.
//
import SwiftUI

struct TransactionCard: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isPayable: Bool
}

struct HSTMatchView: View {
    @State private var transactions: [TransactionCard] = [
        TransactionCard(text: "Sold goods for $500 + HST", isPayable: true),
        TransactionCard(text: "Bought office supplies for $200 + HST", isPayable: false),
        TransactionCard(text: "Sold services for $800 + HST", isPayable: true),
        TransactionCard(text: "Bought new computer for $1000 + HST", isPayable: false)
    ].shuffled()
    
    @State private var matchedPayable: [TransactionCard] = []
    @State private var matchedRecoverable: [TransactionCard] = []
    @State private var feedback = ""
    @AppStorage("gamesPlayed") private var gamesPlayed = 0
    @AppStorage("correctTotal") private var correctTotal = 0
    var body: some View {
        VStack(spacing: 30) {
            Text("🏷️ HST Account Match")
                .font(.title2).bold()
            
            Text("Drag each transaction to the correct HST account:")
                .multilineTextAlignment(.center)
            
            HStack(spacing: 40) {
                VStack {
                    Text("💸 HST Payable")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    DropArea(targetList: $matchedPayable, isPayableArea: true)
                        .frame(minHeight: 150)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                }
                
                VStack {
                    Text("💰 HST Recoverable")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    DropArea(targetList: $matchedRecoverable, isPayableArea: false)
                        .frame(minHeight: 150)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding()

            VStack(spacing: 12) {
                Text("🃏 Transactions")
                    .font(.headline)
                ForEach(transactions) { card in
                    Text(card.text)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .onDrag {
                            return NSItemProvider(object: NSString(string: card.text))
                        }
                        .accessibilityIdentifier(card.isPayable ? "payable" : "recoverable")
                }
            }

            Button("Check Answers") {
                checkMatches()
            }
            .padding(.top, 20)

            if !feedback.isEmpty {
                Text(feedback)
                    .foregroundColor(.primary)
                    .padding()
            }
        }
        .padding()
    }
    
    func checkMatches() {
        let correctPayable = matchedPayable.filter { $0.isPayable }.count
        let correctRecoverable = matchedRecoverable.filter { !$0.isPayable }.count
        let total = matchedPayable.count + matchedRecoverable.count
        let correct = correctPayable + correctRecoverable
        
        // Update persistent stats
        gamesPlayed += 1
        correctTotal += correct
        
        feedback = """
        ✅ You matched \(correct) out of \(total) correctly!
        📊 Total Correct Across Games: \(correctTotal)
        🎮 Games Played: \(gamesPlayed)
        """
    }

}

struct DropArea: View {
    @Binding var targetList: [TransactionCard]
    var isPayableArea: Bool

    var body: some View {
        VStack {
            ForEach(targetList) { item in
                Text(item.text)
                    .font(.caption)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(isPayableArea ? Color.blue.opacity(0.4) : Color.green.opacity(0.4))
                    .cornerRadius(8)
            }
        }
        .onDrop(of: [.text], isTargeted: nil) { providers in
            providers.first?.loadItem(forTypeIdentifier: "public.text", options: nil) { (item, _) in
                if let data = item as? Data,
                   let text = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        let isPayable = isPayableArea
                        let matchedCard = TransactionCard(text: text, isPayable: isPayable)
                        if !targetList.contains(matchedCard) {
                            targetList.append(matchedCard)
                        }
                    }
                }
            }
            return true
        }
    }
}

#Preview {
    HSTMatchView()
}
