//
//  ContentView.swift
//  WordGarden
//
//  Created by Tushar Munge on 6/7/25.
//

import AVFAudio
import SwiftUI

extension View {
    func hidden(_ hideView: Bool) -> some View {
        opacity(hideView ? 0 : 1)
    }
}

struct ContentView: View {
    private var wordsToGuess = ["SWIFT", "DOG", "CAT"]  // All CAPS
    // Have to define as 'static', so that it can be used to intialize
    // above. Structs don't alow initializing of member variables with others
    private static let maximumGuesses = 8

    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var currentWordIndex = 0  // Index in wordToGuess
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = maximumGuesses
    @State private var gameStatusMessage =
        "How many guesses to uncover the Hidden Word?"
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var playAgainHidden = true
    @State private var audioPlayer: AVAudioPlayer!
    @FocusState private var textFieldIsFocused: Bool

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
                    Text("Words in Game: \(wordsToGuess.count)")
                }
            }
            .padding(.horizontal)

            Spacer()

            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80.0)
                .minimumScaleFactor(0.5)
                .padding()

            //TODO: Switch to wordsToGuess[currentWordIndex]
            Text(revealedWord)
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
                        // All the modifiers below are to setup the keyboard
                        // to accept only specific input
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .focused($textFieldIsFocused)
                        .onChange(of: guessedLetter) {
                            guessedLetter = guessedLetter.trimmingCharacters(
                                in: .letters.inverted
                            )

                            guard let lastChar = guessedLetter.last else {
                                return
                            }

                            guessedLetter = String(lastChar).uppercased()
                        }
                        .onSubmit {
                            // As long as guessedLetter is not an empty
                            // string, we can continue, otherwise don't
                            // do anything
                            guard guessedLetter != "" else {
                                return
                            }

                            guessALetter()
                            updateGamePlay()
                        }

                    Button("Guess a Letter") {
                        guessALetter()
                        updateGamePlay()

                        textFieldIsFocused = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                Button(playAgainButtonLabel) {
                    // If all of the words have been guessed
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }

                    // Reset after a word was guessed or missed
                    wordToGuess = wordsToGuess[currentWordIndex]

                    // For every letter in wordToGuess, construct revealedWord
                    // by substituting each letter with an '_', separated
                    // by a Whitespace
                    revealedWord = wordToGuess.map { letter in "_" }.joined(
                        separator: " "
                    )

                    lettersGuessed = ""
                    guessesRemaining = Self.maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage =
                        "How many guesses to uncover the Hidden Word?"
                    playAgainHidden = true
                    textFieldIsFocused = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }

            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75), value: imageName)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            wordToGuess = wordsToGuess[currentWordIndex]

            // For every letter in wordToGuess, construct revealedWord
            // by substituting each letter with an '_', separated
            // by a Whitespace
            revealedWord = wordToGuess.map { letter in "_" }.joined(
                separator: " "
            )

            textFieldIsFocused = true
        }
    }

    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed += guessedLetter

        revealedWord = wordToGuess.map {
            lettersGuessed.contains($0) ? "\($0)" : "_"
        }.joined(separator: " ")
    }

    func updateGamePlay() {
        // Deduct 1 from guessesRemaining, if the wrong letter was guessed, or
        // the already guessed letter was guessed again
        if !wordToGuess.contains(guessedLetter)
            || (lettersGuessed.contains(guessedLetter)
                && lettersGuessed.count > 1
                && guessesRemaining == Self.maximumGuesses)
        {
            guessesRemaining -= 1

            // Animate crumbling leaf and play the incorrect sound
            imageName = "wilt\(guessesRemaining)"

            playSound(soundName: "incorrect")

            // Delay change to the Flower image until after the wilt
            // animation is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }
        } else {
            playSound(soundName: "correct")
        }

        // When do we play another Word? When revealedWord does not
        // contain an '_'
        if !revealedWord.contains("_") {
            gameStatusMessage =
                "You guessed it! It took you \(lettersGuessed.count) guesses to guess the Word."

            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false

            playSound(soundName: "word-guessed")
        } else if guessesRemaining == 0 {
            gameStatusMessage = "So sorry, you're all out if Guesses."

            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false

            playSound(soundName: "word-not-guessed")
        } else {
            //TODO: Redo this with LocalizedStringKey & Inflection
            gameStatusMessage =
                "You've made ^[\(lettersGuessed.count) guesses](inflect: true)"
        }

        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage +=
                "\nYou've tried all of the Words. Restart from the beginning?"
        }

        guessedLetter = ""
    }

    func playSound(soundName: String) {
        // Prior to playing a sound, check if it's already playing one.
        // If it is, stop it. This prevents overlapping sounds from
        // playing.
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }

        //TODO: - Get the Sound file -
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")

            return
        }

        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print(
                "😡 ERROR: \(error.localizedDescription) creating audioPlayer"
            )
        }
    }
}

#Preview {
    ContentView()
}
