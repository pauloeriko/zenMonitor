import SwiftUI

@main
struct ZenMonitorApp: App {
    @State private var processManager = ProcessManager()
    
    // Logique de couleur basée sur la charge Système réelle (plus pertinent)
    var statusColor: Color {
        if processManager.systemLoad < 10 {
            return .green
        } else if processManager.systemLoad < 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 0) {
                
                // --- Bloc Statistiques ---
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vue d'ensemble")
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    // Ligne 1 : Charge réelle (comme Moniteur d'activité)
                    HStack {
                        Text("Charge Système :")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f%%", processManager.systemLoad))
                            .bold()
                    }
                    
                    // Ligne 2 : Charge brute (Somme des coeurs)
                    HStack {
                        Text("Somme Coeurs (Unix) :")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.0f%%", processManager.totalCPU))
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
                .padding()
                
                Divider()
                
                // --- Liste des Apps ---
                Text("Top Consommateurs")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)
                
                ForEach(processManager.topProcesses) { process in
                    ProcessRowView(process: process) {
                        processManager.killProcess(pid: process.id)
                    }
                }
                
                if processManager.topProcesses.isEmpty {
                    Text("Aucun processus actif")
                        .font(.caption)
                        .padding()
                }
                
                Divider()
                
                // --- Bouton Quitter ---
                Button("Quitter ZenMonitor") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        } label: {
            // Affichage Barre de Menu : Charge Système Globale
            Text("CPU: \(String(format: "%.0f", processManager.systemLoad))%")
                .foregroundColor(statusColor)
        }
        .menuBarExtraStyle(.window)
    }
}
