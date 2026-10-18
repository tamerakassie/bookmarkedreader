import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject var library: Library
    @AppStorage("lastOpenedBookID") private var lastOpenedBookID = ""

    @State private var showImporter = false
    @State private var path: [Book] = []
    @State private var hasRestored = false      // only auto-open once per launch

    var body: some View {
        NavigationStack(path: $path) {
            List(library.books) { book in
                NavigationLink(value: book) {
                    HStack {
                        Text(book.title)
                        Spacer()
                        if let page = book.bookmarkedPage {
                            Label("p. \(page + 1)", systemImage: "bookmark.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .overlay {
                if library.books.isEmpty {
                    Text("Tap + to add a PDF").foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Library")
            .toolbar {
                Button { showImporter = true } label: { Image(systemName: "plus") }
            }
            .navigationDestination(for: Book.self) { book in
                ReaderView(book: book)
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.pdf]) { result in
                if case .success(let url) = result { library.importPDF(from: url) }
            }
            .onAppear(perform: restoreLastBook)
        }
    }

    private func restoreLastBook() {
        guard !hasRestored else { return }
        hasRestored = true
        if let id = UUID(uuidString: lastOpenedBookID),
           let book = library.book(withID: id) {
            path = [book]
        }
    }
}
