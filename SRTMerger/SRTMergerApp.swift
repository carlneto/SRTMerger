import SwiftUI
import UniformTypeIdentifiers
import Combine
import UtilsPackage

// MARK: - ViewModel

@MainActor
class AppViewModel: NSObject, ObservableObject {
   @Published var inputFileName: String = "Selecione um ficheiro .srt"
   @Published var processedSubtitles: Subtitles = []
   @Published var showSuccessMessage: Bool = false
   @Published var successMessage: String = ""
   @Published var isProcessing: Bool = false
   @Published var processingMode: ProcessingMode = .merge
   @Published var maxGap2Merge: TimeInterval = 0.0
   @Published var maxDuration: TimeInterval = 5.5
   @Published var splitCharacters: String = "\n,.!?;:-\"'»…>—_"
   @Published var splitMethod: SplitMethod = .byAll
   var originalSubtitles: Subtitles = []
   /// Opens dialog to select an .srt file
   func openSRTFile() {
      let panel = NSOpenPanel()
      panel.allowedContentTypes = [UTType(filenameExtension: "srt") ?? .plainText]
      panel.allowsMultipleSelection = false
      panel.canChooseDirectories = false
      panel.canChooseFiles = true
      if panel.runModal() == .OK, let url = panel.urls.first {
         loadAndProcessFile(url: url)
      }
   }
   /// Loads and processes an .srt file
   private func loadAndProcessFile(url: URL) {
      isProcessing = true
      DispatchQueue.global(qos: .userInitiated).async {
         do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let subtitles = Subtitles(content: content)
            DispatchQueue.main.async {
               self.inputFileName = url.lastPathComponent
               self.process(subtitles: subtitles)
               self.isProcessing = false
            }
         } catch {
            DispatchQueue.main.async {
               self.successMessage = "Erro ao ler ficheiro: \(error.localizedDescription)"
               self.showSuccessMessage = true
               self.isProcessing = false
            }
         }
      }
   }
   /// Processes subtitles based on current mode and settings
   func process(subtitles: Subtitles) {
      if let minGap = subtitles.minGap { self.maxGap2Merge = minGap }
      self.originalSubtitles = subtitles
      self.processOriginalSubtitles()
   }
   func processOriginalSubtitles() {
      self.processedSubtitles = self.originalSubtitles
         .processed(processingMode: self.processingMode, maxGap2Merge: self.maxGap2Merge,
                    maxDuration: self.maxDuration, splitCharacters: self.splitCharacters, splitMethod: self.splitMethod)
   }
   /// Saves processed results to new .srt file
   func saveSRTFile() {
      let srtContent = processedSubtitles.strString
      let panel = NSSavePanel()
      panel.allowedContentTypes = [UTType(filenameExtension: "srt") ?? .plainText]
      panel.nameFieldStringValue = "legendas_processadas_\(self.processingMode.str).srt"
      if panel.runModal() == .OK, let url = panel.url {
         do {
            try srtContent.write(to: url, atomically: true, encoding: .utf8)
            originalSubtitles = processedSubtitles
            successMessage = "Ficheiro guardado com sucesso!"
            showSuccessMessage = true
         } catch {
            successMessage = "Erro ao guardar ficheiro: \(error.localizedDescription)"
            showSuccessMessage = true
         }
      }
   }
   /// Saves processed results to new .srt file with markers
   func saveRawFile() {
      let srtContent = processedSubtitles.rawString
      let panel = NSSavePanel()
      panel.allowedContentTypes = [UTType(filenameExtension: "srt") ?? .plainText]
      panel.nameFieldStringValue = "legendas_marcadas_\(self.processingMode.str).srt"
      if panel.runModal() == .OK, let url = panel.url {
         do {
            try srtContent.write(to: url, atomically: true, encoding: .utf8)
            successMessage = "Ficheiro guardado com sucesso!"
            showSuccessMessage = true
         } catch {
            successMessage = "Erro ao guardar ficheiro: \(error.localizedDescription)"
            showSuccessMessage = true
         }
      }
   }
}

// MARK: - Main Application

@main
struct SRTMergerApp: App {
   @StateObject private var viewModel = AppViewModel()
   var body: some Scene {
      WindowGroup {
         ContentView()
            .environmentObject(viewModel)
      }
      .windowStyle(.hiddenTitleBar)
      .windowResizability(.automatic)
   }
}
