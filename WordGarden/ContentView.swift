//
//  ContentView.swift
//  WordGarden
//
//  Created by Tushar Munge on 6/7/25.
//

import SwiftUI

extension View {
    func hidden(_ hideView: Bool) -> some View {
        opacity(hideView ? 0 : 1)
    }
}

struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var wordsToGuess = ["SWIFT", "DOG", "CAT"] // All CAPS
    @State private var currentWord = 0 // Index in wordToGuess
    @State private var gameStatusMessage =
        "How Many Guesses to Uncover the Hidden Word?"
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Word Guessed: \(wordsGuessed)")
                    Text("Word Missed: \(wordsMissed)")
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(
                        "Word to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))"
                    )
                    Text("Word in Game: \(wordsToGuess.count)")
                }
            }
            .padding(.horizontal)

            Spacer()

            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            //TODO: Switch to wordsToGuess[currentWord]
            Text("_ _ _ _ _")
                .font(.title)
            
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30.0)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(Color.gray, lineWidth: 2.0)
                        }
                    
                    Button("Guess a Letter") {
                        //TODO: Guess a Letter Button Action here
                        playAgainHidden = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                }
            } else {
                Button("Another Word?") {
                    //TODO: Another Word Button Action here
                    playAgainHidden = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
            
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ContentView()
}
