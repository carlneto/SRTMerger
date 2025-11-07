import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Modelos de Dados

/// Representa uma entrada de legenda com tempo de início, fim e texto
struct Subtitle {
   let startTime: TimeInterval
   let endTime: TimeInterval
   let text: String
}

/// Representa um ficheiro .srt processado
struct SRTFile {
   var subtitles: [Subtitle]

   /// Transforma a representação interna em formato .srt válido
   func toSRTString() -> String {
      var result = ""
      for (index, subtitle) in subtitles.enumerated() {
         let startString = timeToSRTFormat(subtitle.startTime)
         let endString = timeToSRTFormat(subtitle.endTime)

         result += "\(index + 1)\n"
         result += "\(startString) --> \(endString)\n"
         result += "\(subtitle.text)\n"
         if index < subtitles.count - 1 {
            result += "\n"
         }
      }
      return result
   }

   func toRawString() -> String {
      var raw = """
         Traduz integralmente o texto seguinte para português de Portugal, garantindo que:
         1. Manténs as marcas originais (#1#, #2#, #3#, etc.) exatamente nas mesmas posições, sem as mover nem eliminar.
         2. A tradução é correta, natural e fluida, em registo oral (adequado para vídeo ou locução), sem jargão.
         3. O texto traduzido deve ocupar aproximadamente o mesmo tempo de fala que o original, permitindo que cada legenda mantenha a sincronização com o vídeo (adaptações leves de extensão são permitidas para manter ritmo e naturalidade).
         4. Corrige integralmente erros de escrita, ortografia, pontuação e maiúsculas.
         5. Converte medidas e moedas para o sistema métrico e Euro.
         6. Não utilizes formatação adicional, não cries listas nem quebras de linha artificiais — devolve o texto contínuo, exatamente como o original, apenas traduzido e corrigido.
         7. Garante uma tradução fiel no conteúdo e tom, mas ajustada ao português de Portugal e ao tempo de leitura típico das legendas originais.
         Devolve apenas o texto contínuo traduzido, sem comentários nem formatação extra.\n\n
         """
      for (idx, subttl) in subtitles.enumerated() {
         let cardinal = idx + 1
         let caption = subttl.text
         let replacd = caption.replacedSpacesAndLines
         raw += "#\(cardinal)#\(replacd) "
      }
      return raw
   }

   /// Converte TimeInterval para formato SRT (HH:MM:SS,ms)
   private func timeToSRTFormat(_ time: TimeInterval) -> String {
      let hours = Int(time) / 3600
      let minutes = (Int(time) % 3600) / 60
      let seconds = Int(time) % 60
      let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)

      return String(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds)
   }
}

// MARK: - Parser SRT

class SRTParser {
   /// Analisa o conteúdo de um ficheiro .srt e extrai as legendas
   static func parse(_ content: String) -> [Subtitle] {
      let lines = content.components(separatedBy: .newlines)
      var subtitles: [Subtitle] = []
      var currentIndex = 0

      while currentIndex < lines.count {
         let line = lines[currentIndex].trimmingCharacters(in: .whitespaces)

         // Procura a linha de índice (número da legenda)
         if line.isEmpty || !line.allSatisfy({ $0.isNumber }) {
            currentIndex += 1
            continue
         }

         // Obtém a linha de tempos
         guard currentIndex + 1 < lines.count else { break }
         let timingLine = lines[currentIndex + 1].trimmingCharacters(in: .whitespaces)

         // Extrai os tempos de início e fim
         guard let (startTime, endTime) = parseTiming(timingLine) else {
            currentIndex += 2
            continue
         }

         // Recolhe o texto (pode estar em múltiplas linhas)
         var textLines: [String] = []
         currentIndex += 2

         while currentIndex < lines.count {
            let textLine = lines[currentIndex].trimmingCharacters(in: .whitespaces)
            if textLine.isEmpty {
               break
            }
            textLines.append(textLine)
            currentIndex += 1
         }

         let text = textLines.joined(separator: "\n")
         if !text.isEmpty {
            subtitles.append(Subtitle(startTime: startTime, endTime: endTime, text: text))
         }
      }

      return subtitles
   }

   /// Converte formato SRT (HH:MM:SS,ms) para TimeInterval
   private static func parseTiming(_ timing: String) -> (TimeInterval, TimeInterval)? {
      let components = timing.components(separatedBy: " --> ")
      guard components.count == 2 else { return nil }

      guard let startTime = parseTime(components[0].trimmingCharacters(in: .whitespaces)),
            let endTime = parseTime(components[1].trimmingCharacters(in: .whitespaces)) else {
         return nil
      }

      return (startTime, endTime)
   }

   /// Converte um timestamp SRT para TimeInterval
   private static func parseTime(_ timeString: String) -> TimeInterval? {
      let components = timeString.replacingOccurrences(of: ",", with: ".").components(separatedBy: ":")
      guard components.count == 3 else { return nil }

      guard let hours = Double(components[0]),
            let minutes = Double(components[1]),
            let seconds = Double(components[2]) else {
         return nil
      }

      return hours * 3600 + minutes * 60 + seconds
   }
}

// MARK: - Processador de Legendas

class SubtitleProcessor {
   /// Une legendas consecutivas quando o intervalo é inferior a maxGap
   static func mergeCloseSubtitles(_ subtitles: [Subtitle], maxGap: TimeInterval = 1.0) -> [Subtitle] {
      guard !subtitles.isEmpty else { return [] }

      var merged: [Subtitle] = []
      var currentSubtitle = subtitles[0]

      for i in 1..<subtitles.count {
         let nextSubtitle = subtitles[i]
         let gap = nextSubtitle.startTime - currentSubtitle.endTime

         // Se a diferença for menor que maxGap, une as legendas
         if gap < maxGap && gap >= 0 {
            currentSubtitle = Subtitle(
               startTime: currentSubtitle.startTime,
               endTime: nextSubtitle.endTime,
               text: currentSubtitle.text + " " + nextSubtitle.text
            )
         } else {
            merged.append(currentSubtitle)
            currentSubtitle = nextSubtitle
         }
      }

      merged.append(currentSubtitle)
      return merged
   }
}

// MARK: - ViewModel

@MainActor
class AppViewModel: NSObject, ObservableObject {
   @Published var inputFileName: String = "Selecione um ficheiro .srt"
   @Published var processedSubtitles: [Subtitle] = []
   @Published var showSuccessMessage: Bool = false
   @Published var successMessage: String = ""
   @Published var isProcessing: Bool = false
   @Published var maxGap: TimeInterval = 0.0

   private var originalSubtitles: [Subtitle] = []

   /// Abre um diálogo para selecionar um ficheiro .srt
   func selectSRTFile() {
      let panel = NSOpenPanel()
      panel.allowedContentTypes = [UTType(filenameExtension: "srt") ?? .plainText]
      panel.allowsMultipleSelection = false
      panel.canChooseDirectories = false
      panel.canChooseFiles = true

      if panel.runModal() == .OK, let url = panel.urls.first {
         loadAndProcessFile(url: url)
      }
   }

   /// Carrega e processa um ficheiro .srt
   private func loadAndProcessFile(url: URL) {
      isProcessing = true

      DispatchQueue.global(qos: .userInitiated).async {
         do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let subtitles = SRTParser.parse(content)

            DispatchQueue.main.async {
               self.originalSubtitles = subtitles
               self.inputFileName = url.lastPathComponent
               self.processSubtitles()
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

   /// Processa as legendas com o valor atual de maxGap
   func processSubtitles() {
      let mergedSubtitles = SubtitleProcessor.mergeCloseSubtitles(originalSubtitles, maxGap: maxGap)
      self.processedSubtitles = mergedSubtitles
   }

   /// Guarda os resultados processados num novo ficheiro .srt
   func saveSRTFile() {
      let srtFile = SRTFile(subtitles: processedSubtitles)
      let srtContent = srtFile.toSRTString()

      let panel = NSSavePanel()
      panel.allowedContentTypes = [UTType(filenameExtension: "srt") ?? .plainText]
      panel.nameFieldStringValue = "legendas_processadas.srt"

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

   /// Guarda os resultados processados num novo ficheiro .srt
   func saveRawFile() {
      let srtFile = SRTFile(subtitles: processedSubtitles)
      let srtContent = srtFile.toRawString()

      let panel = NSSavePanel()
      panel.allowedContentTypes = [UTType(filenameExtension: "srt") ?? .plainText]
      panel.nameFieldStringValue = "legendas_marcadas.srt"

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

extension String {
   func replacedOccurrences(of regex: String, with text: String = "") -> String {
      let str = self
      guard let range = str.range(of: regex, options: .regularExpression, range: nil, locale: nil) else { return str }
      let matched = String(str[range])
      return str.replacingOccurrences(of: matched, with: text)
   }
   var dupSpacesCleaned: String { self.replacedOccurrences(of: "\\s+", with: " ") }
   var replacedNewLines: String { self.replacedOccurrences(of: "\\n+", with: " ") }
   var replacedSpacesAndLines: String { self.replacedNewLines.dupSpacesCleaned }
}

// MARK: - Interface Principal

struct ContentView: View {
   @StateObject private var viewModel = AppViewModel()

   var body: some View {
      VStack(spacing: 20) {
         // Cabeçalho
         VStack(alignment: .leading, spacing: 8) {
            Text("Processador de Legendas SRT")
               .font(.title)
               .fontWeight(.bold)

            Text("Importe um ficheiro de legendas e as entradas próximas serão automaticamente unidas")
               .font(.subheadline)
               .foregroundColor(.secondary)
         }
         .frame(maxWidth: .infinity, alignment: .leading)
         .padding()
         .background(Color.gray.opacity(0.1))
         .cornerRadius(8)

         // Secção de Carregamento
         VStack(spacing: 12) {
            HStack {
               Image(systemName: "doc.text")
                  .font(.title3)

               Text(viewModel.inputFileName)
                  .lineLimit(1)

               Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(6)

            Button(action: viewModel.selectSRTFile) {
               HStack {
                  Image(systemName: "folder.open")
                  Text("Selecionar Ficheiro")
               }
               .frame(maxWidth: .infinity)
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .cornerRadius(6)
            }
            .disabled(viewModel.isProcessing)
         }

         // Controlo de maxGap
         if !viewModel.processedSubtitles.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
               HStack {
                  Text("Distância Máxima entre Legendas")
                     .font(.headline)

                  Spacer()

                  Text("\(String(format: "%.3f", viewModel.maxGap))s")
                     .font(.caption)
                     .fontWeight(.bold)
                     .foregroundColor(.blue)
               }

               Slider(value: $viewModel.maxGap, in: 0.0...2.5, step: 0.001)
                  .onChange(of: viewModel.maxGap) {
                     viewModel.processSubtitles()
                  }

               Text("Define o intervalo máximo de tempo (em segundos) entre o fim de uma legenda e o início da próxima para que sejam unidas")
                  .font(.caption)
                  .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(6)
         }

         if !viewModel.processedSubtitles.isEmpty {
            HStack(spacing: 16) {
               VStack(alignment: .leading, spacing: 4) {
                  Text("Legendas Processadas")
                     .font(.caption)
                     .foregroundColor(.secondary)

                  Text("\(viewModel.processedSubtitles.count)")
                     .font(.headline)
               }
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding()
               .background(Color.green.opacity(0.1))
               .cornerRadius(6)

               Spacer()
            }
         }

         // Lista de Legendas Processadas
         if !viewModel.processedSubtitles.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
               Text("Pré-visualização")
                  .font(.headline)

               ScrollView {
                  VStack(alignment: .leading, spacing: 12) {
                     ForEach(Array(viewModel.processedSubtitles.prefix(5).enumerated()), id: \.offset) { index, subtitle in
                        SubtitleRowView(subtitle: subtitle, index: index + 1)
                     }

                     if viewModel.processedSubtitles.count > 5 {
                        Text("... e mais \(viewModel.processedSubtitles.count - 5) legendas")
                           .font(.caption)
                           .foregroundColor(.secondary)
                           .padding()
                     }
                  }
               }
               .background(Color.gray.opacity(0.05))
               .cornerRadius(6)
            }
         }

         Spacer()

         // Botão de Guardar
         if !viewModel.processedSubtitles.isEmpty {
            Button(action: viewModel.saveSRTFile) {
               HStack {
                  Image(systemName: "square.and.arrow.down")
                  Text("Guardar Ficheiro Processado")
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
                  Text("Guardar Ficheiro Marcado")
               }
               .frame(maxWidth: .infinity)
               .padding()
               .background(Color.green)
               .foregroundColor(.white)
               .cornerRadius(6)
            }
         }
      }
      .padding(20)
      .frame(minWidth: 600, minHeight: 500)
      .alert("Mensagem", isPresented: $viewModel.showSuccessMessage) {
         Button("OK", role: .cancel) { }
      } message: {
         Text(viewModel.successMessage)
      }
      .onAppear(perform: viewModel.selectSRTFile)
   }
}

// MARK: - Componentes Auxiliares

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

            Text(formatTime(subtitle.startTime))
               .font(.caption)
               .foregroundColor(.secondary)

            Text("→")
               .font(.caption)
               .foregroundColor(.secondary)

            Text(formatTime(subtitle.endTime))
               .font(.caption)
               .foregroundColor(.secondary)
         }

         Text(subtitle.text)
            .font(.caption)
            .lineLimit(2)
            .foregroundColor(.primary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(8)
      .background(Color.white)
      .cornerRadius(4)
   }

   private func formatTime(_ time: TimeInterval) -> String {
      let time = Swift.abs(time)
      let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)
      let seconds = Int(time) % 60
      let minutes = Int(time) / 60
      let hours = minutes / 60
      let format = time < 0 ? "-%01d:%02d:%02d,%03d" : "%02d:%02d:%02d,%03d"
      return String(format: format, hours, minutes % 60, seconds, milliseconds)
   }
}

// MARK: - Aplicação Principal

@main
struct SRTMergerApp: App {
   var body: some Scene {
      WindowGroup {
         ContentView()
      }
      .windowStyle(.hiddenTitleBar)
      .windowResizability(.automatic)
   }
}
