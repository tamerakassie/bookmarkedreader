import Foundation

struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var fileName: String          // name of our private copy inside the app's Documents folder
    var bookmarkedPage: Int?      // zero-based page index; nil = no bookmark yet
}
