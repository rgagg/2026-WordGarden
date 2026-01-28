//
//  ContentView.swift
//  WordGarden
//
//  Created by Richard Gagg on 27/1/2026.
//

import SwiftUI

struct ContentView: View {
  
  @State private var wordsGuesses: Int = 0
  @State private var WordsMissed: Int = 0
  @State private var gameStatusMessage: String = "How Many Guesses to Uncover the Hidden Word?"
  @State private var currentWord: Int = 0 // Index of wordsToGuess array
  @State private var guessedLetter: String = ""
  @State private var imageName: String = "flower8"
  @State private var playAgainIsHidden: Bool = true
  @FocusState private var textFieldIsFocussed: Bool
  
  @State private var  wordsToGuess: [String] = [
    "SWIFT",
    "DOG",
    "CAT",
    "HOUSE",
    "WORLD"
  ] // All caps
  
  var body: some View {
    VStack {
      
      HStack {
        VStack(alignment: .leading) {
          Text("Words Guessed: \(wordsGuesses)")
          Text("Words Missed: \(WordsMissed)")
        }
        
        Spacer()
        
        VStack(alignment: .trailing) {
          Text("Words To Guess: \(wordsToGuess.count - (wordsGuesses + WordsMissed))")
          Text("Words in Game: \(wordsToGuess.count)")
        }
      }
      .padding(.horizontal, 20)
      
      Spacer()
      
      Text(gameStatusMessage)
        .font(.title)
        .multilineTextAlignment(.center)
        .padding()
      
      Text("_ _ _ _ _")
        .font(.title)
        .multilineTextAlignment(.center)
      
      if playAgainIsHidden {
        HStack {
          TextField("", text: $guessedLetter)
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .frame(width: 35)
            .overlay {
              RoundedRectangle(cornerRadius: 5)
                .stroke(.gray, lineWidth: 2)
            }
            .keyboardType(.asciiCapable)
            .submitLabel(.done)
            .autocorrectionDisabled(true)
//            .textInputAutocapitalization(.characters)
            .onChange(of: guessedLetter) {
              guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
              guard let lastChar = guessedLetter.last else {
                return
              }
              guessedLetter = String(lastChar).uppercased()
            }
            .focused($textFieldIsFocussed)
         
          Button {
            // Guess Action
            textFieldIsFocussed = false
          } label: {
            Text("Guess A Letter")
              .font(.title3)
              .foregroundStyle(.blue)
              .fontWeight(.bold)
          }
          .buttonStyle(.bordered)
          .tint(.mint)
          .disabled(guessedLetter.isEmpty)
        }
      } else {
        
        Button {
          // Play Again Action
        } label: {
          Text("Play Again?")
            .font(.title3)
            .foregroundStyle(.blue)
            .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
        .tint(.mint)
      }
      
      Spacer()
      
      Image(imageName)
        .resizable()
        .scaledToFit()
    }
    .ignoresSafeArea(edges: .bottom)  }
}






#Preview("Light Mode") {
  ContentView()
    .preferredColorScheme(ColorScheme.light)
}

#Preview("Dark Mode") {
  ContentView()
    .preferredColorScheme(ColorScheme.dark)
}
