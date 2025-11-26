import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "wave.3.right.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .padding()

                Text("NFC Writer & Reader")
                    .font(.largeTitle)
                    .bold()

                NavigationLink("📤 Gravar TAG NFC") {
                    WriteNFCView()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("📥 Ler TAG NFC") {
                    ReadNFCView()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
        }
    }
}