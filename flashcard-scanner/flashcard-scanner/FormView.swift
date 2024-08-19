import SwiftUI

struct Flashcard {
    var mainPhrase: String
    var example: String
    var flashcardNumber: String
    var mainPhraseTranslation: String
    var exampleTranslation: String
    
    init(mainPhrase: String, example: String, flashcardNumber: String, mainPhraseTranslation: String, exampleTranslation: String) {
        self.mainPhrase = mainPhrase
        self.example = example
        self.flashcardNumber = flashcardNumber
        self.mainPhraseTranslation = mainPhraseTranslation
        self.exampleTranslation = exampleTranslation
    }
    
    init() {
        self.init(mainPhrase: "", example: "", flashcardNumber: "", mainPhraseTranslation: "", exampleTranslation: "")
    }
    
}

struct FormView: View {
    @State var scannedText: [String] = []
    @State var frontSideText: [String] = [] // Text recognized from the front side of the card
    
    @State var card = Flashcard()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                BasicTextRow(card: $card, scannedText: $scannedText, frontSideText: $frontSideText)
            }
        }
        .listStyle(.plain)
        
        .navigationTitle("FlashCard Scanner")
        .navigationBarTitleDisplayMode(.automatic)
    }
}


struct BasicTextRow: View {
    
    @Binding var card: Flashcard
    @Binding var scannedText: [String]
    @Binding var frontSideText: [String]
        
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                SelectionView(frontSideText: $frontSideText, scannedText: $scannedText, card: $card, fieldTag: 0, label: "Phrase")
                SelectionView(frontSideText: $frontSideText, scannedText: $scannedText, card: $card, fieldTag: 1, label: "Translation")
                SelectionView(frontSideText: $frontSideText, scannedText: $scannedText, card: $card, fieldTag: 2, label: "Example")
                SelectionView(frontSideText: $frontSideText, scannedText: $scannedText, card: $card, fieldTag: 3, label: "Ex. translation")
                SelectionView(frontSideText: $frontSideText, scannedText: $scannedText, card: $card, fieldTag: 4, label: "Card No.")
                    
                HStack {
                    Spacer() // This pushes the button to the center/
                    NavigationLink(destination: EditView(card: $card)) {
                        Text("Edit")
                            .foregroundColor(.blue)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                    }
                    Spacer() // This keeps the button centered
                }                    
                
                HStack {
                    Spacer() // This pushes the button to the center/
                    Text("Save")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            saveFlashcardToFile(flashcard: card)
                            print("Saved flashcard: \(card)")
                            
                            // Clear the current flashcard for new input
                            card = Flashcard()
                            scannedText = []
                            frontSideText = []
                            
                        }

                    
                    Spacer() // This keeps the button centered
                }
            }
        }
        .padding()
    }
}


struct EditView: View {
    @Binding var card: Flashcard

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            EditLabelAndTextFied(label: "Phrase", tag: 0, textValue: $card.mainPhrase, card: $card)
            EditLabelAndTextFied(label: "Translation", tag: 1, textValue: $card.mainPhraseTranslation, card: $card)
            EditLabelAndTextFied(label: "Example", tag: 2, textValue: $card.example, card: $card)
            EditLabelAndTextFied(label: "Example translation", tag: 3, textValue: $card.exampleTranslation, card: $card)
            EditLabelAndTextFied(label: "Card No.", tag: 4, textValue: $card.flashcardNumber, card: $card)
        }
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
        .padding()
        .navigationTitle("Edit Data")
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct EditLabelAndTextFied: View {
    var label: String
    var tag: Int
    @Binding var textValue: String
    @Binding var card: Flashcard
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(.darkGray))
            
            TextField("Edit data...", text: $textValue)
                .font(.system(.body, design: .rounded))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .focused($isFocused)
                .onChange(of: isFocused) { wasFocused, isFocused in
                    if !isFocused {
                        updateFlashcard(field: tag, with: textValue)
                    }
                }
                .padding(.vertical, 10)
        }
    }
    
    func updateFlashcard(field tag: Int, with text: String) {
        switch tag {
        case 0:
            card.mainPhrase = text
        case 1:
            card.mainPhraseTranslation = text
        case 2:
            card.example = text
        case 3:
            card.exampleTranslation = text
        case 4:
            card.flashcardNumber = text
        default:
            break
        }
    }
}

struct SelectionView: View {
    
    @State private var showActionSheet = false
    @Binding var frontSideText: [String]
    @Binding var scannedText: [String]
    @Binding var card: Flashcard
    var fieldTag: Int
    var label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(.darkGray))
            
            TextField("Tap to select text...", text: Binding(
                get: { self.textForFieldTag() },
                set: { newValue in self.updateFlashcard(field: self.fieldTag, with: newValue) }
            ))
            .font(.system(.body, design: .rounded))
            .textFieldStyle(PlainTextFieldStyle())
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .padding(.vertical, 10)
            .onTapGesture {
                showActionSheet = true
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            actionSheet()
        }
    }
    
    func actionSheet() -> ActionSheet {
        let textOptions = frontSideText + scannedText
        
        return ActionSheet(
            title: Text("Select Text"),
            buttons: textOptions.map { text in
                    .default(Text(text)) {
                        let updatedText: String
                        if !textForFieldTag().isEmpty {
                            updatedText = textForFieldTag() + " " + text
                        } else {
                            updatedText = text
                        }
                        updateFlashcard(field: fieldTag, with: updatedText)
                    }
            } + [.cancel()]
        )
    }
    
    func textForFieldTag() -> String {
        switch fieldTag {
        case 0:
            return card.mainPhrase
        case 1:
            return card.mainPhraseTranslation
        case 2:
            return card.example
        case 3:
            return card.exampleTranslation
        case 4:
            return card.flashcardNumber
        default:
            return ""
        }
    }

    func updateFlashcard(field tag: Int, with text: String) {
        switch tag {
        case 0:
            card.mainPhrase = text
        case 1:
            card.mainPhraseTranslation = text
        case 2:
            card.example = text
        case 3:
            card.exampleTranslation = text
        case 4:
            card.flashcardNumber = text
        default:
            break
        }
    }
}

extension Flashcard {
    func toString() -> String {
        return "\(mainPhrase) | \(example) (\(flashcardNumber)),\(mainPhraseTranslation) | \(exampleTranslation)"
    }
}

func saveFlashcardToFile(flashcard: Flashcard, filename: String = "flashcards.csv") {
    let fileManager = FileManager.default
    
    // Get the path to the "On My iPhone" or "On My iPad" directory
    guard let sharedDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Flashcards", isDirectory: true) else {
        print("Failed to get shared directory.")
        return
    }
    
    // Ensure the directory exists
    do {
        try fileManager.createDirectory(at: sharedDirectory, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Failed to create directory: \(error.localizedDescription)")
        return
    }
    
    // Construct the full file path
    let fileURL = sharedDirectory.appendingPathComponent(filename)
    
    let flashcardString = flashcard.toString() + "\n\n" // Add some spacing between flashcards
    
    do {
        if fileManager.fileExists(atPath: fileURL.path) {
            // Append to the existing file
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = flashcardString.data(using: .utf8) {
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }
        } else {
            // Create the file and write the first flashcard
            try flashcardString.write(to: fileURL, atomically: true, encoding: .utf8)
        }
        print("Flashcard saved to \(fileURL.path)")
    } catch {
        print("Failed to save flashcard: \(error.localizedDescription)")
    }
}


//struct FormView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Use @State to wrap arrays so that they can be passed as Binding
//        @State var frontSideText: [String] = ["Option 1", "Option 2"]
//        @State var scannedText: [String] = ["Scanned 1", "Scanned 2"]
//        
//        FormView()
//        
//        BasicTextRow(
//            card: .constant(Flashcard(
//            mainPhrase: "Hola", example: "Some example", flashcardNumber: "97", mainPhraseTranslation: "Cześć", exampleTranslation: "Tłumaczeniee po polsku"
//        )),
//            scannedText: $scannedText,  // Pass as Binding
//            frontSideText: $frontSideText  // Pass as Binding
//        )
//            .previewLayout(.sizeThatFits)
//    }
//}
