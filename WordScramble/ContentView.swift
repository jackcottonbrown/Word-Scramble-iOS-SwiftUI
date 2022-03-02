//
//  ContentView.swift
//  WordScramble
//
//  Created by Jack Cotton-Brown on 6/12/21.
//
/*
 Todo:
 -navigation view
 -list view separated out with sections
 -text field for word entry
 -load in the word list from the txt file, store it in a string array
 -create an array to store each entered word so they show in the list view
 -use a forEach to build the list of user entered words
 -set the challenge word to be equal to a random word from the txt file
 -create a dynamic alert that gives the user
 -create a function that checks if the word is possible
 -create a function that checks if the word is a real word
 -create a function that checks the word hasn't already been submitted (isOriginal)
 -create a function that dynamically adjusts the error alert
 -turn off auto spelling correction
 -Disallow answers that are too short, or are the same as the starting word
 -Create a function that can find all the possible words, and store them in an array.
 -All real words needs to be a set to remove any duplicates
 -Focus the keyboard on the enter a word text field always.
 */

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var userWords = [String]()
    @State private var numberOfCorrectWords = 0
    @State private var textFieldString = ""
    @State private var challengeWord = ""
    @State private var score = 0
    @State private var challengeCharacters = [String]()
    @State private var allPossiblePermutations = [String]()
    @State private var allRealWords = Set<String>()
    @State private var scrabbleDictionarySet = Set<String>()
    @State private var numberOfRealWords = 0
    @FocusState private var enterWordFocused: Bool
    

    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorIsShowing = false
    
    var body: some View {
        NavigationView{
            List {
                Section{
                    TextField("Enter a 3+ letter word",text: $textFieldString)
                        .focused($enterWordFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onSubmit {
                            addWord()
                            enterWordFocused = true
                        }

                    
                }
                
                Section{
                    ForEach(userWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)

                        }
                        
                    }
                }
                
//                Section{
//                    ForEach((allRealWords.map {String($0)}), id: \.self){ word in
//                        HStack{
//                            Image(systemName: "\(word.count).circle")
//                            Text(word)
//
//                        }
//
//                    }
//                }
            }
            .navigationTitle(challengeWord)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button{
                        startGame()
                    } label: {
                        Text("New Game")
                            .font(.system(size: 20)).bold()
                            .padding()
                            .background()
                            .buttonBorderShape(.roundedRectangle)
                            .foregroundColor(.blue)
                            .shadow(radius: 2)
                    }
                    
                    Text("Score: \(score)")
                        .font(.system(size: 20)).bold()
                        .padding()
                        .background()
                        .foregroundColor(.green)
                        .shadow(radius: 2)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Text("Words found: \(numberOfCorrectWords) / \(numberOfRealWords)")
                        .font(.system(size: 20)).bold()
                        .padding()
                        .background()
                        .foregroundColor(.green)
                        .shadow(radius: 2)
                }
            }
        }

        .onAppear {
            buildScrabbleDictionary()
            startGame()
            createChallengeCharactersArray()
            allPossiblePermutations = combinations(array: challengeCharacters)
            buildRealWordsSet(permutations: allPossiblePermutations)
            numberOfRealWords = allRealWords.count
        }
        .alert(errorTitle, isPresented: $errorIsShowing) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }
    
    func startGame(){
        //reset all game values
        score = 0
        userWords = [String]()
        challengeCharacters = [String]()
        allPossiblePermutations = [String]()
        allRealWords = Set<String>()
        numberOfCorrectWords = 0
        
        createChallengeCharactersArray()
        allPossiblePermutations = combinations(array: challengeCharacters)
        buildRealWordsSet(permutations: allPossiblePermutations)
        numberOfRealWords = allRealWords.count
        
        
        //create the URL to the word file
        if let wordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //load the contents of the URL into a String
            if let contents = try? String(contentsOf: wordsURL) {
                //Split the String up into an Array of strings separated by new lines
                var contentsArray = [String]()
                contentsArray = contents.components(separatedBy: "\n")
                
                //assign a random element of the array to the challenge word String
                challengeWord = contentsArray.randomElement() ?? "couldn't find a word"
                return
            }
        }
        fatalError("Couldn't load the words file")
    }
    
    func buildScrabbleDictionary(){ //initialise the scrabble dictionary set
        if let scrabbleDictionaryURL = Bundle.main.url(forResource: "scrabble", withExtension: "txt") {
            //load the contents of the URL into a String
            if let contents = try? String(contentsOf: scrabbleDictionaryURL).lowercased() {
                //Split the String up into an Array of strings separated by new lines
                var contentsArray = [String]()
                contentsArray = contents.components(separatedBy: "\r\n")
                scrabbleDictionarySet = Set(contentsArray)
                return
            }
        }
        fatalError("Couldn't load the scrabble dictionary file")
    }
    
    func addWord(){
        //handle all the logic for checking the user generated word
        //clean the user entered word
        let cleanedWord = textFieldString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit if the word has zero characters
        guard cleanedWord.count > 0 else { return }
        
        guard checkWordIsReal(word: cleanedWord) else{
            showWordError(title: "Word not recognised!", message: "You need to use real words")
            textFieldString = ""
            return
        }
        
        guard checkWordIsOriginal(word: cleanedWord) else{
            showWordError(title: "Already used!", message: "You can only use each word once.")
            textFieldString = ""
            return
        }
        
        guard checkWordIsLegal(word: cleanedWord) else{
            showWordError(title: "Word Not Legal", message: "That word just doesn't seem to fit!")
            textFieldString = ""
            return
        }
        
        guard checkWordIsNotChallengeWord(word: cleanedWord) else{
            showWordError(title: "No Cheating!", message: "You can't use the challenge word!")
            textFieldString = ""
            return
        }
        
        guard checkWordIsNotTooShort(word: cleanedWord) else{
            showWordError(title: "Too Short!", message: "Your words must be longer than 2 characters.")
            textFieldString = ""
            return
        }
        
        withAnimation {
            userWords.insert(cleanedWord, at: 0)
            numberOfCorrectWords = userWords.count
        }
        
        //calculate the score after inserting the new word
        calculateScore()
        
        //reset the text field to empty
        textFieldString = ""
    }
    
    func checkWordIsOriginal(word: String) -> Bool {
        //if the word is already in the array, return false
        return !userWords.contains(word)
    }
    
    func checkWordIsLegal(word: String) -> Bool {
        //check that each of the letters from the entered word can be found in the challenge word and return true if so. Careful about duplicate characters.
        var tempWord = challengeWord
        
        for letter in word {
            //find the first index of the character and remove it
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {return false}
        }
        return true
    }
    
    func checkWordIsReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func checkWordIsNotChallengeWord(word: String) -> Bool{
        if word == challengeWord {
            return false
        }
        return true
    }
    
    func checkWordIsNotTooShort(word: String) -> Bool{
        if word.count <= 2{
            return false
        }
        return true
    }
    
    func calculateScore(){ //Nest this in the addWord function
        /*
         3 letter words = 3 points. 1x
         4 letter words = 8 points. 2x
         5 letter words = 15 points. 3x
         6 letter words = 24 points. 4x etc...
         */
        score = 0
        withAnimation {
            for string in userWords{
                score += (string.count - 2) * string.count
            }
            }
    }
    
    
    func combinations(array : [String]) -> [String] {

        // Recursion terminates here:
        if array.count == 0 { return [] }

        // Concatenate all combinations that can be built with element #i at the
        // first place, where i runs through all array indices:
        return array.indices.flatMap { i -> [String] in

            // Pick element #i and remove it from the array:
            var arrayMinusOne = array
            let elem = arrayMinusOne.remove(at: i)

            // Prepend element to all combinations of the smaller array:
            return [elem] + combinations(array: arrayMinusOne).map { elem + $0 }
        }
    }
    
    func createChallengeCharactersArray(){
        challengeCharacters = Array(challengeWord).map {String($0)}
    }

    func buildRealWordsSet(permutations: [String]){
        for element in permutations {
            if scrabbleDictionarySet.contains(element) && element.count > 2{
                allRealWords.insert(element)
            }
        }
    }
    
    func showWordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        errorIsShowing = true
    }
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
