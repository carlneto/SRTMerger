# 🎬 SRT Subtitle Processor (Processador de Legendas SRT)

## Descrição

O **Processador de Legendas SRT** é uma aplicação nativa para macOS
desenvolvida em SwiftUI, desenhada para facilitar a edição e
normalização de ficheiros de legendas no formato .srt.

A ferramenta foca-se em dois problemas comuns na sincronização de
legendas:

1.  **Excessiva fragmentação:** Legendas com intervalos muito curtos
    entre si que dificultam a leitura fluida.

2.  **Duração excessiva:** Blocos de texto que permanecem no ecrã por
    demasiado tempo ou contêm demasiado texto.

A aplicação oferece uma interface intuitiva com feedback em tempo real,
estatísticas detalhadas e pré-visualização das alterações antes de
guardar o ficheiro final.

## Requisitos

Para compilar e executar este projeto, são necessários os seguintes
requisitos mínimos:

- **Sistema Operativo:** macOS 13.0 (Ventura) ou superior.

- **Xcode:** Versão 14.3 ou superior.

- **Swift:** Versão 5.7 ou superior.

- **Hardware:** Mac com Apple Silicon (M1/M2/M3) ou Intel.

## Instalação

Como este é um projeto que não utiliza gestores de dependências externos
complexos (como CocoaPods ou Carthage), o processo é direto:

1.  Clone o repositório ou descarregue o código-fonte.

2.  Abra o ficheiro .xcodeproj no Xcode.

3.  Aguarde a indexação do projeto.

4.  Selecione o esquema (scheme) SRTMergerApp.

5.  Pressione Cmd + R para compilar e executar.

## Uso

A interface da aplicação é dividida em secções lógicas:

1.  **Carregamento:** Clique em **\"Selecionar Ficheiro\"** para
    carregar um ficheiro .srt existente ou utilize o botão de \"Dados de
    Teste\" para experimentar a funcionalidade.

2.  **Seleção de Modo:**

    - **Merge (Unir):** Foca-se em unir legendas consecutivas cujo
      intervalo (gap) seja inferior ao definido. Ajuste o slider
      **\"Tempo Máximo entre Legendas\"** para ver as uniões a acontecer
      em tempo real.

    - **Split (Dividir):** Foca-se em dividir legendas longas. Ajuste o
      slider **\"Duração Máxima por Legenda\"** e escolha o **\"Método
      de Distribuição\"** (e.g., por pontuação ou tempo).

3.  **Análise:** Consulte o painel de estatísticas para ver o impacto
    das alterações (redução ou aumento do número de linhas, desvio
    padrão, etc.).

4.  **Pré-visualização:** A lista inferior mostra como as legendas
    ficarão, destacando os tempos de início, fim e duração.

5.  **Guardar:**

    - **\"Aplicar alterações\":** Confirma o processamento atual para a
      memória (permite iterar sobre o resultado).

    - **\"Guardar Processado\":** Exporta o ficheiro .srt final limpo.

    - **\"Guardar Marcado\":** Exporta um ficheiro auxiliar para
      depuração (útil para verificar onde ocorreram os cortes/uniões).

    - **\"Restaurar Backup\":** Reverte para o estado anterior à última
      aplicação.

## Estrutura do Projeto

A organização do código segue o padrão MVVM (Model-View-ViewModel):

SRTMerger/
├── App/
│   ├── SRTMergerApp.swift      // Ponto de entrada da aplicação (Entry Point)
│   └── AppDelegate.swift        // Gestão do ciclo de vida da aplicação
├── View/
│   ├── ContentView.swift        // Ecrã principal e orquestrador de UI
│   ├── SubtitleRowView.swift    // Componente de visualização de uma linha de legenda
│   └── StatisticBox.swift       // Componente reutilizável para estatísticas
├── ViewModel/
│   └── AppViewModel.swift       // Lógica de negócio, gestão de estado e processamento assíncrono
├── Model/
│   ├── Subtitle.swift           // Estrutura de dados da legenda (inferred)
│   ├── ProcessingMode.swift     // Enumeração dos modos de operação (Merge/Split)
│   └── SplitMethod.swift        // Enumeração dos algoritmos de divisão
└── Helpers/
    └── MockDataGenerator.swift  // Gerador de dados fictícios para testes e desenvolvimento

## Funcionalidades Principais

- **Processamento Assíncrono:** Utilização de Swift Concurrency (Tasks)
  para garantir que a UI não bloqueia durante o processamento de
  ficheiros grandes.

- **Merge Inteligente:** União automática baseada em *time gaps*
  configuráveis (precisão ao milissegundo).

- **Split Configurável:** Divisão de legendas baseada na duração máxima
  de exposição (Display Time).

- **Estatísticas em Tempo Real:** Cálculo imediato de métricas como
  desvio padrão, média, máximos e mínimos.

- **Sistema de Backup/Undo:** Pilha de histórico que permite reverter
  alterações aplicadas indevidamente.

- **Mock Mode:** Modo de desenvolvimento integrado para testar a UI sem
  necessidade de ficheiros externos.

## Licença

**ATENÇÃO: SOFTWARE PROPRIETÁRIO.**

Este projeto encontra-se sob uma **Licença de Utilização Restrita**. Não
é Software de Código Aberto (Open Source).

**Resumo das condições (consultar o ficheiro LICENSE ou o cabeçalho do
código para o texto integral):**

- ⛔️ **Proibida** a distribuição, partilha ou venda.

- ⛔️ **Proibida** a engenharia inversa, modificação ou criação de obras
  derivadas.

- ⛔️ **Proibido** o uso comercial.

- ✅ **Permitida** apenas a utilização pessoal e privada para fins de
  avaliação e testes.

Todos os direitos de propriedade intelectual estão reservados ao Autor.
© 2025 Autor.

## Créditos

- **Desenvolvimento:** carlneto

- **Design & Arquitetura:** Baseado em SwiftUI e Swift Concurrency.

