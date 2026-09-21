# 🏋️ GymTracker — Offline Native iOS Workout Tracker

[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue?logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange?logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/Framework-SwiftUI%20%7C%20Swift%20Charts-purple)](https://developer.apple.com/xcode/swiftui/)
[![Offline](https://img.shields.io/badge/Architecture-100%25%20Offline-brightgreen)](https://github.com/joaobarreira05/GYMTRACKER)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

> **"Um caderno de treino físico, transformado numa aplicação iPhone nativa e premium."**

Uma aplicação **iOS nativa exclusivamente para iPhone**, construída em **Swift e SwiftUI**, concebida para ser o apontador digital mais rápido, simples e fluido durante o treino no ginásio.

---

## ✨ Filosofia & Funcionalidades Principais

### 📓 Modo Caderno Digital Diário (Sem Fricção)
- **Zero cronómetros de sessão desnecessários**: Sem relógios a piscar segundos (`00:43:21`) em segundo plano a drenar bateria e CPU.
- **Sem "Iniciar" ou "Finalizar" Treino**: O que apontas no dia de hoje **é o treino de hoje**. Ponto final.
- **Auto-Save Atómico em Tempo Real**: Cada peso, repetição ou nota fica imediatamente guardado na sandbox do iPhone. Se fechares a app ou atenderes uma chamada, nada se perde.

### 🔢 Suporte Nativo a Decimais
- Suporte total para **vírgulas e pontos** (`12,5 kg` ou `12.5 kg`), perfeitamente adaptado ao teclado numérico português e europeu do iOS.

### 📝 Comentários Diretos nos Exercícios
- Caixa de notas/comentários **sempre visível** no cartão de cada exercício (ex: *"Banco inclinação 3, boa carga"*).
- **Cópia inteligente**: Ao clicares em **"Copy to Today"**, todos os comentários dos exercícios acompanham as séries para a nova sessão.

### 🔄 Copiar Treino Passado para Hoje
- No histórico, podes escolher qualquer treino anterior e com 1 toque (**"Copy to Today"**) carregar todos os exercícios e séries desse dia como referência para a folha de hoje.

### ⏱️ Rest Timer Automático (2 Minutos)
- Ao introduzires o peso de uma série, o cronómetro de descanso arranca automaticamente uma contagem decrescente de **02:00 (120s)** em segundo plano com feedback háptico e botão de fechar direto (`x`).

### 📚 Catálogo com 60+ Exercícios em Inglês
- Organizados por **10 grupos musculares**:
  - Chest, Shoulders, Back, Biceps, Triceps
  - Legs — Quadriceps, Hamstrings / Glutes, Calves
  - Abs / Core, Other / Full Body
- Pesquisa instantânea por texto (ex: `press` -> Dumbbell Bench Press, Machine Chest Press, etc.).
- Suporte para criar, editar e apagar **exercícios personalizados**.

### 📈 Gráficos de Evolução & PRs Automáticos
- Cálculo automático de **Recordes Pessoais (PRs)**: Melhor Peso, Melhores Repetições e Maior Volume.
- Gráfico de evolução de carga temporal gerado nativamente com **Swift Charts**.

### 🛡️ Privacidade e Funcionamento 100% Offline
- **Sem backend, sem APIs externas, sem autenticação, sem cloud, sem telemetria**.
- Todos os dados pertencem exclusivamente ao dispositivo (`Application Support Directory`).
- Suporte nativo a **Dark Mode** (otimizado para ecrãs OLED) e unidades em **kg** ou **lb**.
- Exportação local da base de dados em formato JSON através da folha de partilha nativa do iOS (`ShareSheet`).

---

## 🏗️ Arquitetura do Projeto

Construído seguindo o padrão **MVVM** limpo e modular em Swift moderno:

```
GymTracker/
├── App/
│   ├── GymTrackerApp.swift       # Ponto de entrada @main com suporte de tema
│   └── Info.plist                # Configurações do Bundle para iPhone
├── Models/
│   ├── Exercise.swift            # Modelo de exercício e grupos musculares
│   ├── MuscleGroup.swift         # Enum com 10 grupos musculares, ícones SF Symbols e cores
│   ├── Workout.swift             # Modelo diário do treino
│   ├── WorkoutExercise.swift     # Exercício dentro de um treino com séries e notas
│   ├── WorkoutSet.swift          # Série com cálculo de volume e formatação
│   ├── WorkoutTemplate.swift     # Rotinas pré-definidas (Push, Pull, Legs, etc.)
│   └── UserSettings.swift        # Definições (kg/lb, modo escuro, timer)
├── Persistence/
│   ├── DataManager.swift         # Persistência atómica em JSON com cópias seguras
│   ├── SeedData.swift            # 60+ exercícios pré-instalados em inglês e 6 templates
│   └── RestTimerManager.swift    # Gestor do timer de descanso em segundo plano
├── ViewModels/
│   └── GymStore.swift            # ViewModel reativo central com auto-save em tempo real
├── Utilities/
│   └── WorkoutCalculations.swift # Cálculo de PRs, pontos de progresso e formatações
├── Components/
│   ├── HapticFeedback.swift      # Utilitário de vibrações hápticas do iOS
│   ├── QuickStatCard.swift       # Cartões de métricas e estatísticas
│   └── RestTimerOverlay.swift    # Widget flutuante de descanso
└── Views/
    ├── MainTabView.swift         # Navegação por abas inferiores
    ├── Home/                     # Ecrã de início com resumo do dia e modelos
    ├── Workout/                  # Caderno diário de treino (ActiveWorkoutView)
    ├── History/                  # Histórico por dia, detalhe e edição (WorkoutDetailView)
    ├── Exercises/                # Catálogo de exercícios, detalhes, PRs e gráficos
    ├── Templates/                # Gestor de modelos de treino
    └── Settings/                 # Definições, unidades e exportação de dados
```

---

## 🚀 Como Abrir e Correr no iPhone

### Requisitos:
- Mac com **macOS Sonoma / Sequoia / Tahoe**
- **Xcode 15+ ou 16+** (gratuito na Mac App Store)
- iPhone com **iOS 17.0+**

### Passo a Passo:
1. Clona este repositório:
   ```bash
   git clone git@github.com:joaobarreira05/GYMTRACKER.git
   cd GYMTRACKER
   ```
2. Abre o projeto no Xcode dando duplo clique em:
   ```
   GymTracker.xcodeproj
   ```
3. Liga o teu iPhone ao Mac com o cabo USB.
4. No Xcode:
   - No topo da janela, seleciona o teu **iPhone** na lista de destinos;
   - Vai ao separador **Signing & Capabilities** e seleciona o teu **Personal Team** (Apple ID gratuito);
5. Carrega no botão **Play ▶️ (Run)**.
6. A app compila e instala-se diretamente no teu telemóvel!

---

## 📄 Licença

Distribuído sob a licença MIT. Consulta o ficheiro `LICENSE` para mais informações.
