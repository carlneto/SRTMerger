//
//  ContentView.swift
//  ProcessadorDeLegendasSRT
//
//  Created by Autor on 30/11/2025.
//

import SwiftUI
import UtilsPackage

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button("Selecionar Ficheiro") {
                    viewModel.openSRTFile()
                }
                .padding(6)
                
                Spacer()
                
                Picker("Modo de Processamento", selection: $viewModel.processingMode) {
                    Text("Merge").tag(ProcessingMode.merge)
                    Text("Split").tag(ProcessingMode.split)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
                .onChange(of: viewModel.processingMode) { _ in
                    viewModel.processOriginalSubtitles()
                }
            }
            .padding(.horizontal)
            
            Group {
                if viewModel.processingMode == .merge {
                    HStack {
                        Text("Tempo Máximo entre Legendas:")
                        TextField("", value: $viewModel.maxDisplayGapTime, formatter: viewModel.timeFormatter)
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                viewModel.processOriginalSubtitles()
                            }
                        Text("s")
                        Spacer()
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Duração Máxima por Legenda:")
                            TextField("", value: $viewModel.maxDisplayTime, formatter: viewModel.timeFormatter)
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    viewModel.processOriginalSubtitles()
                                }
                            Text("s")
                            Spacer()
                        }
                        HStack {
                            Text("Método de Distribuição de Tempo:")
                            Picker("", selection: $viewModel.splitDistributionMethod) {
                                ForEach(SplitDistributionMethod.allCases, id: \.self) { method in
                                    Text(method.description).tag(method)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Divider()
            
            HStack {
                StatisticBox(title: "Originais", value: "\(viewModel.originalSubtitles.count)")
                StatisticBox(title: "Processadas", value: "\(viewModel.processedSubtitles.count)")
                StatisticBox(title: "Variação", value: viewModel.variationDescription)
                StatisticBox(title: "Duração (s)", value: viewModel.durationStatsDescription)
                StatisticBox(title: "Desvio Padrão (s)", value: viewModel.sdDescription)
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            List {
                ForEach(viewModel.processedSubtitles.prefix(1000)) { subtitle in
                    SubtitleRowView(subtitle: subtitle)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                Button("Aplicar alterações") {
                    viewModel.applyChanges()
                }
                .disabled(!viewModel.hasChanges)
                
                Button("Restaurar Backup") {
                    viewModel.restoreBackup()
                }
                .disabled(!viewModel.hasBackup)
                
                Spacer()
                
                Button("Guardar Processado") {
                    viewModel.saveProcessedFile()
                }
                .disabled(viewModel.processedSubtitles.isEmpty)
                
                Button("Guardar Marcado") {
                    viewModel.saveMarkedFile()
                }
                .disabled(viewModel.processedSubtitles.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct SubtitleRowView: View {
    let subtitle: Subtitle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(subtitle.index)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(subtitle.timeRange.stringRepresentation)
                .font(.caption2)
                .foregroundColor(.gray)
            ForEach(subtitle.textLines, id: \.self) { line in
                Text(line)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }
}

struct StatisticBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(width: 80)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewModel.preview)
    }
}
#endif
