//
//  ContentView.swift
//  WordScramble
//
//  Created by Lucas Chae on 5/3/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var isErrorShowing = false
    
    @State private var userScore = 0
    @FocusState private var isFocused: Bool

    
    
    var body: some View {
        NavigationView {
            List {
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .focused($isFocused)
                    
                } header: {
                    Text("Your current score is \(userScore)")
                        .font(.headline)
                }
                Section {
                    ForEach(usedWords, id: \.self) { item in
                        HStack {
                            Image(systemName: "\(item.count).circle.fill")
                            Text(item)
                        }
                    }
                }
            }
            .toolbar {
                Button("New Word") {
                    startGame()
                    resetGame()
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $isErrorShowing) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2  else {
            wordError(title: "Word too short", text: "Choose a word at least three characters long")
            userScore -= 1
            return
        }
        
        guard !isOriginal(inputWord: answer) else {
            wordError(title: "Word used already", text: "Be more original")
            userScore -= 1
            return
        }
        
        guard isReal(inputWord: answer) else {
            wordError(title: "Word isn't in the dictonary", text: "Be smarter")
            userScore -= 1
            return
        }
        
        guard isPossible(inputWord: answer) else {
            wordError(title: "Word can't be made with root word", text: "Be more accurate")
            userScore -= 1
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        switch answer.count {
        case 3:
            userScore += 1
        case 4:
            userScore += 2
        case 5:
            userScore += 4
        case 6:
            userScore += 7
        case 7:
            userScore += 10
        case 8:
            userScore += 20
        default:
            break
        }
        
        
        isFocused = true
        newWord = ""
        
    }
    
    func startGame() {
        // Check if there is a valid source file for eight letter words
        if let startWordsURL = Bundle.main.url(forResource: "eightLetterWords", withExtension: "txt") {
            // Check (try) if the source file can be turned into String type
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Process the source file (entire string of all words) and divide them into individual words
                let allWords = startWords.components(separatedBy: "\n")
                // Nil coalescing (since randomElement can fail to give an element, which won't happen here)
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(inputWord: String) -> Bool {
        usedWords.contains(inputWord)
    }
    
    func isPossible(inputWord: String) -> Bool {
        var wordChecker = rootWord
        
        for letter in inputWord {
            if let firstCharPos = wordChecker.firstIndex(of: letter) {
                wordChecker.remove(at: firstCharPos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(inputWord: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: inputWord.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: inputWord, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    

    
    func wordError(title: String, text: String) {
        errorTitle = title
        errorMessage = text
        isErrorShowing = true
    }
    
    func countScore() {
        
    }
    
    func resetGame() {
        userScore = 0
        for _ in usedWords {
            withAnimation {
            usedWords.remove(at: 0)
            }
        }
        
    }
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
