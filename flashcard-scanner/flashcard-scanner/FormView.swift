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
                            print("Saved flashcard: \($card)")
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
            EditLabelAndTextFied(label: "Phrase", exisitngText: $card.mainPhrase)
            EditLabelAndTextFied(label: "Translation", exisitngText: $card.mainPhraseTranslation)
            EditLabelAndTextFied(label: "Example", exisitngText: $card.example)
            EditLabelAndTextFied(label: "Example translation", exisitngText: $card.exampleTranslation)
            EditLabelAndTextFied(label: "Card No.", exisitngText: $card.flashcardNumber)
        }
        .padding()
        .navigationTitle("Edit Data")
    }
}

struct EditLabelAndTextFied: View {
    var label: String
    @Binding var exisitngText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(.darkGray))
            
            TextField("Edit data...", text: $exisitngText)
                .font(.system(.body, design: .rounded))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .padding(.vertical, 10)
        }
    }
}

struct SelectionView: View {
    
    @State private var showActionSheet = false
    @State private var selectedText: String = ""
    @State private var cardText: String = ""
    
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
            
            TextField("Tap to select text...", text: $cardText)
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
                        if !cardText.isEmpty {
                            cardText += "\n" + text
                        } else {
                            cardText = text
                        }
                        updateFlashcard(field: fieldTag, with: cardText)
                    }
            } + [.cancel()]
        )
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
