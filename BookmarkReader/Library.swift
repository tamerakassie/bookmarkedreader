import Foundation

@MainActor
final class Library: ObservableObject {
    @Published var books: [Book] = []

    private let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var indexURL: URL { docs.appendingPathComponent("library.json") }

    init() { load() }

    func fileURL(for book: Book) -> URL {
        docs.appendingPathComponent(book.fileName)
    }

    // The picker URL is only temporarily accessible, so we keep our own copy.
    func importPDF(from url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }

        let id = UUID()
        let fileName = "\(id.uuidString).pdf"
        do {
            try FileManager.default.copyItem(at: url, to: docs.appendingPathComponent(fileName))
            let title = url.deletingPathExtension().lastPathComponent
            books.append(Book(id: id, title: title, fileName: fileName, bookmarkedPage: nil))
            save()
        } catch {
            print("Import failed: \(error)")
        }
    }

    func setBookmark(_ page: Int?, for book: Book) {
        guard let i = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[i].bookmarkedPage = page
        save()
    }

    func book(withID id: UUID) -> Book? {
        books.first { $0.id == id }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: indexURL, options: .atomic)
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL),
              let saved = try? JSONDecoder().decode([Book].self, from: data) else { return }
        books = saved
    }
}
