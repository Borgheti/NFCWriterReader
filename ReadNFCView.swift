import SwiftUI
import CoreNFC

struct ReadNFCView: View {
    @State private var status = "Aproxime a TAG para ler."

    var body: some View {
        VStack(spacing: 20) {
            Button("Ler TAG") {
                readNFC()
            }
            .buttonStyle(.borderedProminent)

            Text(status)
                .padding()

            Spacer()
        }
        .navigationTitle("Ler TAG")
        .padding()
    }

    func readNFC() {
        guard NFCNDEFReaderSession.readingAvailable else {
            status = "NFC não disponível."
            return
        }

        let session = NFCNDEFReaderSession(delegate: NFCReader(status: $status), queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Aproxime sua TAG NFC."
        session.begin()
    }
}

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    @Binding var status: String

    init(status: Binding<String>) {
        self._status = status
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.status = "Erro: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        if let record = messages.first?.records.first,
           let text = String(data: record.payload, encoding: .utf8) {
            DispatchQueue.main.async {
                self.status = "Conteúdo da TAG: \(text)"
            }
        }
        session.invalidate()
    }
}