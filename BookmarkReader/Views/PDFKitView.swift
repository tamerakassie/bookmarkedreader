import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL
    let startPage: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)

        // Deferred so the view is laid out first; otherwise the jump is sometimes ignored.
        DispatchQueue.main.async {
            if let page = pdfView.document?.page(at: startPage) {
                pdfView.go(to: page)
            }
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject {
        var parent: PDFKitView
        init(_ parent: PDFKitView) { self.parent = parent }

        @objc func pageChanged(_ note: Notification) {
            guard let view = note.object as? PDFView,
                  let page = view.currentPage,
                  let doc = view.document else { return }
            parent.currentPage = doc.index(for: page)
        }
    }
}
