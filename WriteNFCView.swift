import SwiftUI
import CoreNFC

struct WriteNFCView: View {
    @State private var message = ""
    @State private var status = "Digite uma mensagem e aproxime a TAG."

    var body: some View {
        VStack(spacing: 20) {
            TextField("Mensagem da TAG...", text: $message)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Gravar TAG") {
                writeNFC()
            }
            .buttonStyle(.borderedProminent)

            Text(status)
                .padding()

            Spacer()
        }
        .navigationTitle("Gravar TAG")
        .padding()
    }

    func writeNFC() {
        guard NFCNDEFTagReaderSession.readingAvailable else {
            status = "NFC não disponível."
            return
        }

        let session = NFCNDEFReaderSession(delegate: NFCWriter(message: message, status: $status), queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Aproxime a TAG NFC para gravar."
        session.begin()
    }
}

class NFCWriter: NSObject, NFCNDEFReaderSessionDelegate {
    var message: String
    @Binding var status: String

    init(message: String, status: Binding<String>) {
        self.message = message
        self._status = status
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.status = "Erro: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        let payload = NFCNDEFPayload(format: .nfcWellKnown, type: "T".data(using: .utf8)!, identifier: Data(),
                                     payload: message.data(using: .utf8)!)

        let ndefMessage = NFCNDEFMessage(records: [payload])
        let tag = tags.first!

        session.connect(to: tag) { error in
            if let error = error {
                self.status = "Erro ao conectar: \(error.localizedDescription)"
                session.invalidate()
                return
            }

            tag.writeNDEF(ndefMessage) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.status = "Erro ao gravar: \(error.localizedDescription)"
                    } else {
                        self.status = "TAG gravada com sucesso!"
                    }
                }
                session.invalidate()
            }
        }
    }
}