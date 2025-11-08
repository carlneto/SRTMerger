import SwiftUI
import UtilsPackage

// MARK: - Main Interface

struct ContentView: View {
   @EnvironmentObject var viewModel: AppViewModel
   var body: some View {
      VStack(spacing: 12) {
         // Header
         HStack(alignment: .center, spacing: 8) {
            Text("Processador de Legendas SRT")
               .font(.title)
               .fontWeight(.bold)
            // Mode Selection
            if !viewModel.processedSubtitles.isEmpty {
               Spacer()
               HStack(alignment: .center, spacing: 8) {
                  Text("Modo de Processamento")
                     .font(.headline)
                  Picker("Modo", selection: $viewModel.processingMode) {
                     ForEach(ProcessingMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                     }
                  }
                  .pickerStyle(.segmented)
                  .onChange(of: viewModel.processingMode) {
                     viewModel.processOriginalSubtitles()
                  }
               }
               .padding()
               .background(Color.purple.opacity(0.1))
               .cornerRadius(6)
               Spacer()
            }
            Image(systemName: "doc.text")
               .font(.title3)
            Text(viewModel.inputFileName)
               .lineLimit(1)
            Button(action: viewModel.openSRTFile) {
               HStack {
                  Image(systemName: "folder.fill")
                  Text("Selecionar Ficheiro")
               }
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .cornerRadius(6)
            }
            .disabled(viewModel.isProcessing)
         }
         .frame(maxWidth: .infinity, alignment: .leading)
         .padding()
         .background(Color.gray.opacity(0.1))
         .cornerRadius(8)
         // Merge Mode Controls
         if !viewModel.processedSubtitles.isEmpty && viewModel.processingMode == .merge {
            VStack(alignment: .leading, spacing: 8) {
               HStack {
                  Text("Tempo Máximo entre Legendas")
                     .font(.headline)
                  Spacer()
                  Text("\(String(format: "%.3f", viewModel.maxGap2Merge))s")
                     .font(.caption)
                     .fontWeight(.bold)
                     .foregroundColor(.blue)
               }
               Slider(value: $viewModel.maxGap2Merge, in: 0.0...5.0, step: 0.001)
                  .onChange(of: viewModel.maxGap2Merge) {
                     viewModel.processOriginalSubtitles()
                  }
               Text("Legendas com intervalo inferior serão unidas automaticamente")
                  .font(.caption)
                  .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(6)
         }
         // Split Mode Controls
         if !viewModel.processedSubtitles.isEmpty && viewModel.processingMode == .split {
            VStack(alignment: .leading, spacing: 8) {
               // Max Duration
               VStack(alignment: .leading, spacing: 8) {
                  HStack {
                     Text("Duração Máxima por Legenda")
                        .font(.headline)
                     Text("Legendas mais longas serão divididas automaticamente")
                        .font(.caption)
                        .foregroundColor(.secondary)
                     Spacer()
                     Text("\(String(format: "%.1f", viewModel.maxDuration))s")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                  }
                  Slider(value: $viewModel.maxDuration, in: 2.0...300.0, step: 0.5)
                     .onChange(of: viewModel.maxDuration) {
                        viewModel.processOriginalSubtitles()
                     }
               }
               // Split Characters
               HStack(alignment: .center, spacing: 8) {
                  Text("Caracteres de Divisão")
                     .font(.headline)
                  Text("Pontuação usada para dividir o texto")
                     .font(.caption)
                     .foregroundColor(.secondary)
                  Spacer()
                  TextField("Ex: ,.", text: $viewModel.splitCharacters)
                     .textFieldStyle(.roundedBorder)
                     .onChange(of: viewModel.splitCharacters) {
                        viewModel.processOriginalSubtitles()
                     }
               }
               // Split Method
               HStack(alignment: .center, spacing: 8) {
                  Text("Método de Distribuição de Tempo")
                     .font(.headline)
                  Picker("Método", selection: $viewModel.splitMethod) {
                     ForEach(SplitMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                     }
                  }
                  .pickerStyle(.menu)
                  .onChange(of: viewModel.splitMethod) {
                     viewModel.processOriginalSubtitles()
                  }
                  Text(viewModel.splitMethod.description)
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .fixedSize(horizontal: false, vertical: true)
               }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(6)
         }
         // Statistics
         if !viewModel.processedSubtitles.isEmpty {
            HStack(spacing: 8) {
               StatisticBox(
                  title: "Original",
                  value: "\(viewModel.originalSubtitles.count)",
                  color: .gray
               )
               StatisticBox(
                  title: "Processadas",
                  value: "\(viewModel.processedSubtitles.count)",
                  color: .green
               )
               let difference = viewModel.processedSubtitles.count - viewModel.originalSubtitles.count
               StatisticBox(
                  title: viewModel.processingMode == .merge ? "Redução" : "Aumento",
                  value: difference > 0 ? "+\(difference)" : "\(difference)",
                  color: viewModel.processingMode == .merge ? .blue : .orange
               )
            }
         }
         // Preview List
         if !viewModel.processedSubtitles.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
               HStack {
                  Text("Pré-visualização (\(viewModel.processingMode.rawValue))")
                     .font(.headline)
                  Spacer()
                  Text("Total: \(viewModel.processedSubtitles.count) legendas")
                     .font(.caption)
                     .fontWeight(.bold)
                     .foregroundColor(.orange)
               }
               ScrollView {
                  VStack(alignment: .leading, spacing: 12) {
                     ForEach(Array(viewModel.processedSubtitles.prefix(1000).enumerated()), id: \.offset) { index, subtitle in
                        SubtitleRowView(subtitle: subtitle, index: index + 1)
                     }
                     if viewModel.processedSubtitles.count > 1000 {
                        Text("... e mais \(viewModel.processedSubtitles.count - 1000) legendas")
                           .font(.caption)
                           .foregroundColor(.secondary)
                           .padding()
                     }
                  }
               }
               .frame(minHeight: 200)
               .background(Color.gray.opacity(0.05))
               .cornerRadius(6)
            }
         }
         Spacer()
         // Save Buttons
         if !viewModel.processedSubtitles.isEmpty {
            HStack(spacing: 12) {
               Button(action: viewModel.saveSRTFile) {
                  HStack {
                     Image(systemName: "square.and.arrow.down")
                     Text("Guardar Processado")
                  }
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.green)
                  .foregroundColor(.white)
                  .cornerRadius(6)
               }
               Button(action: viewModel.saveRawFile) {
                  HStack {
                     Image(systemName: "square.and.arrow.down")
                     Text("Guardar Marcado")
                  }
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.green)
                  .foregroundColor(.white)
                  .cornerRadius(6)
               }
            }
         }
      }
      .padding(20)
      .frame(minWidth: 700, minHeight: 700)
      .alert("Mensagem", isPresented: $viewModel.showSuccessMessage) {
         Button("OK", role: .cancel) { }
      } message: {
         Text(viewModel.successMessage)
      }
   }
}

// MARK: - Auxiliary Components

struct StatisticBox: View {
   let title: String
   let value: String
   let color: Color

   var body: some View {
      HStack(alignment: .center, spacing: 4) {
         Text(title)
            .font(.caption)
            .foregroundColor(.secondary)

         Text(value)
            .font(.headline)
            .foregroundColor(color)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(color.opacity(0.1))
      .cornerRadius(6)
   }
}
struct SubtitleRowView: View {
   let subtitle: Subtitle
   let index: Int
   var body: some View {
      VStack(alignment: .leading, spacing: 6) {
         HStack {
            Text("#\(index)")
               .font(.caption)
               .fontWeight(.bold)
               .foregroundColor(.white)
               .frame(width: 30, height: 20)
               .background(Color.blue)
               .cornerRadius(4)

            Text(subtitle.startTime.hms)
               .font(.caption)
               .foregroundColor(.secondary)

            Text("→")
               .font(.caption)
               .foregroundColor(.secondary)

            Text(subtitle.stopTime.hms)
               .font(.caption)
               .foregroundColor(.secondary)

            Spacer()

            Text("(\(String(format: "%.1f", subtitle.srtDuration))s)")
               .font(.caption)
               .foregroundColor(.orange)
         }

         Text(subtitle.caption)
            .font(.caption)
            .foregroundColor(.primary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(8)
      .background(Color.white)
      .cornerRadius(4)
   }
}

// MARK: - Mock Data Generator

class MockDataGenerator {
   // Generate sample SRT subtitles for testing
   static func generateMockSubtitles() -> Subtitles {
      return [
         Subtitle(
            cardinal: 1,
            startTime: 0.0,
            stopTime: 2.5,
            caption: "Welcome to the subtitle processor."
         ),
         Subtitle(
            cardinal: 2,
            startTime: 2.6,
            stopTime: 5.0,
            caption: "This tool helps you merge and split subtitles."
         ),
         Subtitle(
            cardinal: 3,
            startTime: 5.1,
            stopTime: 7.8,
            caption: "You can adjust the maximum gap between subtitles."
         ),
         Subtitle(
            cardinal: 4,
            startTime: 7.85,
            stopTime: 10.2,
            caption: "Short gap here, should merge easily."
         ),
         Subtitle(
            cardinal: 5,
            startTime: 12.5,
            stopTime: 18.0,
            caption: "This is a very long subtitle that should be split into multiple parts when using split mode, especially with punctuation marks like commas, periods, and other separators."
         ),
         Subtitle(
            cardinal: 6,
            startTime: 18.5,
            stopTime: 21.0,
            caption: "Another normal subtitle here."
         ),
         Subtitle(
            cardinal: 7,
            startTime: 21.05,
            stopTime: 23.5,
            caption: "Very close to previous one."
         ),
         Subtitle(
            cardinal: 8,
            startTime: 25.0,
            stopTime: 35.0,
            caption: "First sentence is here. Second sentence follows. Third one too. And finally, the fourth sentence completes this long subtitle."
         ),
         Subtitle(
            cardinal: 9,
            startTime: 36.0,
            stopTime: 38.5,
            caption: "Regular subtitle again."
         ),
         Subtitle(
            cardinal: 10,
            startTime: 38.6,
            stopTime: 41.0,
            caption: "Close gap for merging test."
         ),
         Subtitle(
            cardinal: 11,
            startTime: 43.0,
            stopTime: 45.5,
            caption: "Larger gap before this one."
         ),
         Subtitle(
            cardinal: 12,
            startTime: 45.6,
            stopTime: 55.0,
            caption: "Long duration subtitle: This one goes on for a while, with multiple sentences. It should be split. Because it's too long. Even with multiple points of division."
         ),
         Subtitle(
            cardinal: 13,
            startTime: 56.0,
            stopTime: 58.0,
            caption: "Short one."
         ),
         Subtitle(
            cardinal: 14,
            startTime: 58.05,
            stopTime: 60.5,
            caption: "Tiny gap merge candidate."
         ),
         Subtitle(
            cardinal: 15,
            startTime: 61.0,
            stopTime: 63.5,
            caption: "Final subtitle in sequence."
         )
      ]
   }
   // Generate SRT file content as string
   static func generateMockSRTContent() -> String {
      let subtitles = generateMockSubtitles()
      var srtContent = ""
      for subtitle in subtitles {
         srtContent += "\(subtitle.cardinal)\n"
         srtContent += "\(subtitle.startTime.hms) --> \(subtitle.stopTime.hms)\n"
         srtContent += "\(subtitle.caption)\n\n"
      }
      return srtContent
   }

   // Save mock file to temporary location
   static func saveMockSRTFile() -> URL? {
      let tempDir = FileManager.default.temporaryDirectory
      let fileURL = tempDir.appendingPathComponent("mock_subtitles.srt")

      do {
         try generateMockSRTContent().write(to: fileURL, atomically: true, encoding: .utf8)
         L(comment: "Mock SRT file created at: \(fileURL.path)")
         return fileURL
      } catch {
         L(comment: "Error saving mock file: \(error)")
         return nil
      }
   }
}

// MARK: - Mock ViewModel Extension

extension AppViewModel {
   // Load mock data for testing without file picker
   func loadMockData() {
      DispatchQueue.main.async {
         self.isProcessing = true
         self.inputFileName = "mock_subtitles.srt"
         self.process(subtitles: MockDataGenerator.generateMockSubtitles())
      }
   }
}

// MARK: - Test View with Mock Controls

struct ContentViewWithMock: View {
   @StateObject private var viewModel = AppViewModel()
   var body: some View {
      VStack(spacing: 12) {
         // Mock Data Controls
         HStack {
            Button(action: {
               viewModel.loadMockData()
            }) {
               HStack {
                  Image(systemName: "wand.and.stars")
                  Text("Carregar Dados de Teste")
               }
               .padding()
               .background(Color.purple)
               .foregroundColor(.white)
               .cornerRadius(6)
            }
            Button(action: {
               if let fileURL = MockDataGenerator.saveMockSRTFile() {
                  print("Open this file: \(fileURL.path)")
                  NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
               }
            }) {
               HStack {
                  Image(systemName: "doc.badge.plus")
                  Text("Criar Ficheiro SRT de Teste")
               }
               .padding()
               .background(Color.orange)
               .foregroundColor(.white)
               .cornerRadius(6)
            }
            Spacer()
         }
         .frame(height: 36)
         .padding()
         .background(Color.yellow.opacity(0.2))
         .cornerRadius(8)
         // Original ContentView
         ContentView()
            .environmentObject(viewModel)
      }
      .padding(20)
   }
}
// MARK: - Mock Statistics View
struct MockStatisticsView: View {
   let subtitles: Subtitles
   var body: some View {
      VStack(alignment: .leading, spacing: 12) {
         Text("Estatísticas dos Dados de Teste")
            .font(.headline)
         Group {
            HStack {
               Text("Total de Legendas:")
               Spacer()
               Text("\(subtitles.count)")
                  .fontWeight(.bold)
            }
            HStack {
               Text("Duração Total:")
               Spacer()
               Text("\(String(format: "%.1f", calculateTotalDuration()))s")
                  .fontWeight(.bold)
            }
            HStack {
               Text("Duração Média:")
               Spacer()
               Text("\(String(format: "%.1f", calculateAverageDuration()))s")
                  .fontWeight(.bold)
            }
            HStack {
               Text("Intervalo Médio:")
               Spacer()
               Text("\(String(format: "%.3f", calculateAverageGap()))s")
                  .fontWeight(.bold)
            }
            HStack {
               Text("Legendas Longas (>7s):")
               Spacer()
               Text("\(countLongSubtitles())")
                  .fontWeight(.bold)
                  .foregroundColor(.orange)
            }
            HStack {
               Text("Intervalos Pequenos (<0.1s):")
               Spacer()
               Text("\(countSmallGaps())")
                  .fontWeight(.bold)
                  .foregroundColor(.blue)
            }
         }
         .font(.caption)
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(8)
   }
   private func calculateTotalDuration() -> Double {
      subtitles.reduce(0) { $0 + $1.srtDuration }
   }
   private func calculateAverageDuration() -> Double {
      guard !subtitles.isEmpty else { return 0 }
      return calculateTotalDuration() / Double(subtitles.count)
   }
   private func calculateAverageGap() -> Double {
      guard subtitles.count > 1 else { return 0 }
      var totalGap: Double = 0
      for i in 0..<(subtitles.count - 1) {
         let gap = subtitles[i + 1].startTime - subtitles[i].stopTime
         totalGap += gap
      }
      return totalGap / Double(subtitles.count - 1)
   }
   private func countLongSubtitles() -> Int {
      subtitles.filter { $0.srtDuration > 7.0 }.count
   }
   private func countSmallGaps() -> Int {
      guard subtitles.count > 1 else { return 0 }
      var count = 0
      for i in 0..<(subtitles.count - 1) {
         let gap = subtitles[i + 1].startTime - subtitles[i].stopTime
         if gap < 0.1 {
            count += 1
         }
      }
      return count
   }
}

// MARK: - Preview with Mock

//#Preview("App with Mock Data") {
//   ContentViewWithMock()
//}
//
//#Preview("Mock Statistics") {
//   MockStatisticsView(subtitles: MockDataGenerator.generateMockSubtitles())
//      .frame(width: 400)
//}
