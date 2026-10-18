import SwiftUI

@main
struct BookmarkReaderApp: App {
    @StateObject private var library = Library()

    var body: some Scene {
        WindowGroup {
            LibraryView().environmentObject(library)
        }
    }
}
