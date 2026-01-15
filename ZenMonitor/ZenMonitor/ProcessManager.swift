import Foundation
import SwiftUI

// Structure simple pour représenter un processus
struct AppProcess: Identifiable, Sendable {
    let id: Int // Le PID agit comme ID unique
    let name: String
    let cpuUsage: Double
}

@MainActor
@Observable
class ProcessManager {
    var topProcesses: [AppProcess] = []
    var totalCPU: Double = 0.0 // Vision "Unix" (Somme des cœurs, peut dépasser 100%)
    
    // Récupération du nombre de cœurs (Physiques + Virtuels)
    let processorCount = Double(ProcessInfo.processInfo.activeProcessorCount)
    
    // Vision "Système" (Celle du Moniteur d'activité, normalisée sur 100%)
    var systemLoad: Double {
        return totalCPU / processorCount
    }
    
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        Task { await fetchProcesses() }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchProcesses()
            }
        }
    }
    
    func fetchProcesses() async {
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-Aceo", "pid,%cpu,comm"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Force le format numérique anglais (point au lieu de virgule)
        var env = ProcessInfo.processInfo.environment
        env["LC_NUMERIC"] = "C"
        task.environment = env
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                parseOutput(output)
            }
        } catch {
            print("Erreur lors de l'exécution de ps: \(error)")
        }
    }
    
    private func parseOutput(_ output: String) {
        var newProcesses: [AppProcess] = []
        let lines = output.components(separatedBy: .newlines).dropFirst() // On saute le header
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            // Format: PID   %CPU   COMMAND
            let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            
            if parts.count >= 3,
               let pid = Int(parts[0]),
               let cpu = Double(parts[1]) {
                
                // Reconstruire le nom (cas où le nom contient des espaces)
                let nameParts = parts.dropFirst(2)
                let name = nameParts.joined(separator: " ")
                
                // Filtres de sécurité
                if name == "kernel_task" || name == "WindowServer" { continue }
                
                newProcesses.append(AppProcess(id: pid, name: name, cpuUsage: cpu))
            }
        }
        
        // Calcul du total CPU "Unix"
        self.totalCPU = newProcesses.reduce(0) { $0 + $1.cpuUsage }
        
        // Tri décroissant et Top 5
        self.topProcesses = Array(newProcesses.sorted { $0.cpuUsage > $1.cpuUsage }.prefix(5))
    }
    
    func killProcess(pid: Int) {
        let task = Process()
        task.launchPath = "/bin/kill"
        task.arguments = ["-9", "\(pid)"]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                print("Processus \(pid) tué.")
                Task { await fetchProcesses() } // Rafraîchissement immédiat
            }
        } catch {
            print("Erreur kill: \(error)")
        }
    }
}
