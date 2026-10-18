import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var library: Library
    @AppStorage("lastOpenedBookID") private var lastOpenedBookID = ""

    let book: Book
    @State private var currentPage = 0

    private var isBookmarked: Bool {
        library.book(withID: book.id)?.bookmarkedPage == currentPage
    }

    var body: some View {
        PDFKitView(
            url: library.fileURL(for: book),
            startPage: library.book(withID: book.id)?.bookmarkedPage ?? 0,
            currentPage: $currentPage
        )
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Tapping again on the bookmarked page removes the bookmark.
                    library.setBookmark(isBookmarked ? nil : currentPage, for: book)
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
        }
        // Cleared on leaving, so the app reopens on the library unless quit inside a book.
        .onAppear { lastOpenedBookID = book.id.uuidString }
        .onDisappear { lastOpenedBookID = "" }
    }
}
