import SwiftUI

struct ProcessRowView: View {
    let process: AppProcess
    var onKill: () -> Void
    
    var body: some View {
        HStack {
            // Nom du processus
            Text(process.name)
                .lineLimit(1)
                .frame(maxWidth: 160, alignment: .leading)
            
            Spacer()
            
            // CPU (On affiche la conso brute de l'app en %)
            Text(String(format: "%.1f%%", process.cpuUsage))
                .monospacedDigit()
                .foregroundColor(.secondary)
                .font(.callout)
            
            // Bouton Kill
            Button(action: onKill) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .help("Forcer à quitter (Kill -9)")
            .padding(.leading, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
