//
//  ContentView.swift
//  WordGarden
//
//  Created by Richard Gagg on 27/1/2026.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
  
  private static let maximumNumberOfGuesses: Int = 8
  // Static allows propery to be availabe before view is created
  // Need to refer to this as self.maximumNumberOfGuesses
  
  @State private var wordsGuesses: Int = 0
  @State private var WordsMissed: Int = 0
  @State private var gameStatusMessage: String = "How Many Guesses to Uncover the Hidden Word?"
  @State private var currentWordIndex: Int = 0 // Index of wordsToGuess array
  @State private var wordToGuess: String = ""
  @State private var revealedWord: String = ""
  @State private var guessedLetter: String = ""
  @State private var lettersGuessed: String = ""
  @State private var guessesRemaining: Int = maximumNumberOfGuesses
  @State private var imageName: String = "flower8"
  @State private var playAgainIsHidden: Bool = true
  @State private var audioPlayer: AVAudioPlayer! //Initialise audio player without data
  @State private var soundIsOn: Bool = true
  
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
          Text("Guesses Made: \(lettersGuessed.count)")
        }
        
        Spacer()
        
        VStack(alignment: .trailing) {
          Text("Words To Guess: \(wordsToGuess.count - (wordsGuesses + WordsMissed))")
          Text("Words in Game: \(wordsToGuess.count)")
          Text("Guesses Remaining: \(guessesRemaining)")
        }
      }
      .frame(minHeight: 80)
      .padding(.horizontal, 10)
      .padding(.top, 5)
      
      /*
      HStack {
        Spacer()

        Text("Sound On: ")
        Toggle("Sound On:", isOn: $soundIsOn)
          .labelsHidden()
          .scaleEffect(0.7)
      }
      .padding(.horizontal, 10)
      .padding(.top, 0)
      */
      
      Spacer()
      
      Text(gameStatusMessage)
        .font(.title)
        .multilineTextAlignment(.center)
        .frame(minHeight: 100)
        .minimumScaleFactor(0.5)
        .padding(.horizontal, 10)
        // .border(Color.blue)
      
      Text(revealedWord)
        .font(.title)
        .multilineTextAlignment(.center)
        .frame(minHeight: 40)
      
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
            .onChange(of: guessedLetter) {
              guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
              guard let lastChar = guessedLetter.last else {
                return
              }
              guessedLetter = String(lastChar).uppercased()
            }
            .focused($textFieldIsFocussed)
            .onSubmit {
              // As long as guessedLetter is not empty we can continue otherwise, dont do anythiong
              guard guessedLetter.isEmpty == false else {
                return
              }
              guessALetter()
              updateGamePlay()
            }
          
          Button {
            // Guess Letter Action
            
            guessALetter()
            updateGamePlay()
            
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
        .frame(height: 45)
        
      } else {
        
        Button {
          // Play Again Action
          resetGame()
        } label: {
          Text("Play Again?")
            .font(.title3)
            .foregroundStyle(.blue)
            .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
        .tint(.mint)
        .frame(height: 45)
        
      }
      
      Spacer()
      
      Image(imageName)
        .resizable()
        .scaledToFit()
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    .ignoresSafeArea(edges: .bottom)
    .onAppear() {
      currentWordIndex = 0
      wordToGuess = wordsToGuess[currentWordIndex]
      revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
      
    }
  }
  
//  Functions
  func guessALetter() {
    textFieldIsFocussed = false
    lettersGuessed += guessedLetter
    
    revealedWord = wordToGuess.map { letter in
      lettersGuessed.contains(letter) ? "\(letter)" : "_"
    }.joined(separator: " ")
    
    textFieldIsFocussed = true
  }
  
  func  updateGamePlay() {
    
    if wordToGuess.contains(guessedLetter) {
      if soundIsOn {
        playSound(soundName: "correct")
      }
      
      gameStatusMessage = "You have made \(lettersGuessed.count) guess\(lettersGuessed.count == 1 ? "" : "es")."

    } else {
      if soundIsOn {
        playSound(soundName: "incorrect")
      }

      guessesRemaining -= 1
      imageName = "flower\(guessesRemaining)"
    }
    
    // When do we play next word?
    if !revealedWord.contains("_") { // Word guessed
      if soundIsOn {
        playSound(soundName: "word-guessed")
      }
      
      gameStatusMessage = "You Got It! It took you \(lettersGuessed.count) guesses to guess the word."
      wordsGuesses += 1
      playAgainIsHidden = false
    } else if guessesRemaining == 0 { // Word missed
      if soundIsOn {
        playSound(soundName: "word-not-guessed")
      }
      
      gameStatusMessage = "Sorry. You are all out of guesses.\nBetter luck next time!"
      WordsMissed += 1
      playAgainIsHidden = false
    }
    
    guessedLetter = ""
    
  }
  
  func playSound(soundName: String) {
    /*
     Import needed module
     import AVFAudio
     
     Declare audio player
     @State private var audioPlayer: AVAudioPlayer! //Initialise audio player without data

     Use the follering function call ensuring you use a
     sound file in the asset catalog
    */
    
    if audioPlayer != nil && audioPlayer.isPlaying {
      audioPlayer.stop()
    }
    
    guard let soundFile = NSDataAsset(name: soundName) else {
      print("🤬 Could not find sound file \(soundName)")
      return
    }
    do {
      audioPlayer = try AVAudioPlayer(data: soundFile.data)
      audioPlayer.play()
    } catch {
      print("🤬 Error: \(error.localizedDescription) creating audio player")
    }
  }
  
  func resetGame() {
    if currentWordIndex == wordsToGuess.count {
      currentWordIndex = 0
    } else {
      currentWordIndex += 1
    }
    
    lettersGuessed = ""
    guessesRemaining = ContentView.maximumNumberOfGuesses
    
    wordToGuess = wordsToGuess[currentWordIndex]
    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    
    imageName = "flower\(guessesRemaining)"
    
    playAgainIsHidden = true
  }
}






#Preview("Light Mode") {
  ContentView()
    .preferredColorScheme(ColorScheme.light)
}

#Preview("Dark Mode") {
  ContentView()
    .preferredColorScheme(ColorScheme.dark)
}
