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

### 🔍 Criação Rápida de Exercícios com Nome Pré-Preenchido
- Ao pesquisar por um exercício na biblioteca ou a meio do treino (ex: `"pall"`):
  - Se ainda não existir, surge de imediato o botão de atalho **`Criar "pall"`**.
  - O ecrã de criação abre já com o nome `"pall"` preenchido e foco automático do teclado, permitindo completar o nome em segundos (ex: `"palloff"`).

### 📈 Histórico de Exercícios & Gráficos de Evolução
- **Diretório Dedicado de Exercícios no Histórico**: Alternador entre **`Treinos`** e **`Exercícios`** na aba de Histórico, com filtros por grupo muscular e lista dos teus recordes pessoais (PR).
- **Gráficos Multi-Métrica com Swift Charts**:
  - **Carga Máxima (kg)**
  - **1RM Estimado** (Fórmula de Epley)
  - **Volume Total Acumulado (kg)**
  - **Melhores Repetições**
- **Resumo de Progressão**: Comparação instantânea entre a primeira e a última sessão (`Início → Atual (+X kg, +Y%)`).
- **Acesso Ubíquo**: Consulta os gráficos e o histórico de qualquer exercício no catálogo, nos treinos passados ou diretamente no cartão do exercício durante o treino ativo.

### 🔔 Gestor de Certificado Apple (7 Dias) & Alerta de 24 Horas
- **Deteção Automática de Expiração**: Lê a data de expiração real do perfil de provisionamento (`embedded.mobileprovision`).
- **Notificação Antecipada Configurável**: Agenda no iOS alertas locais com antecedência de **24 horas**, **4 horas** ou ambos, lembrando-te de ligar o iPhone ao Mac antes de a app expirar.
- **Definições & Teste Rápido**: Monitor de dias/horas restantes, botão de teste de notificação em 5 segundos e guia passo a passo de renovação.

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
│   ├── GymTrackerApp.swift                # Ponto de entrada @main com suporte de tema e inicialização de alertas
│   └── Info.plist                         # Configurações do Bundle para iPhone
├── Models/
│   ├── Exercise.swift                     # Modelo de exercício e grupos musculares
│   ├── MuscleGroup.swift                  # Enum com 10 grupos musculares, ícones SF Symbols e cores
│   ├── Workout.swift                      # Modelo diário do treino
│   ├── WorkoutExercise.swift              # Exercício dentro de um treino com séries e notas
│   ├── WorkoutSet.swift                   # Série com cálculo de volume e formatação
│   ├── WorkoutTemplate.swift              # Rotinas pré-definidas (Push, Pull, Legs, etc.)
│   └── UserSettings.swift                 # Definições (kg/lb, modo escuro, timer)
├── Persistence/
│   ├── DataManager.swift                  # Persistência atómica em JSON com cópias seguras
│   ├── SeedData.swift                     # 60+ exercícios pré-instalados em inglês e 6 templates
│   └── RestTimerManager.swift             # Gestor do timer de descanso em segundo plano
├── ViewModels/
│   └── GymStore.swift                     # ViewModel reativo central com auto-save em tempo real
├── Utilities/
│   ├── WorkoutCalculations.swift          # Cálculo de PRs, 1RM (Epley), pontos de progresso e formatações
│   └── CertificateExpirationManager.swift # Gestor de expiração de certificado e agendamento de notificações
├── Components/
│   ├── HapticFeedback.swift               # Utilitário de vibrações hápticas do iOS
│   ├── QuickStatCard.swift                # Cartões de métricas e estatísticas
│   └── RestTimerOverlay.swift             # Widget flutuante de descanso
└── Views/
    ├── MainTabView.swift                  # Navegação por abas inferiores
    ├── Home/                              # Ecrã de início com resumo do dia e modelos
    ├── Workout/                           # Caderno diário de treino (ActiveWorkoutView, WorkoutExerciseCard)
    ├── History/                           # Histórico por treino e evolução por exercício (HistoryView, WorkoutDetailView)
    ├── Exercises/                         # Catálogo de exercícios, AddExerciseSheet e gráficos (ExerciseDetailView)
    ├── Templates/                         # Gestor de modelos de treino
    └── Settings/                          # Definições, validade do certificado, exportação de dados e guia de renovação
```

---

## 🚀 Como Abrir e Correr no iPhone

### Requisitos:
- Mac com **macOS Sonoma / Sequoia / Tahoe**
- **Xcode 15+ ou 16+** (gratuito na Mac App Store)
- iPhone com **iOS 17.0+**

### Passo a Passo de Instalação:
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
5. Carrega no botão **Play ▶️ (Run)** ou prime **`Cmd + R`**.
6. A app compila e instala-se diretamente no teu telemóvel!

---

## 🔄 Como Renovar o Certificado (Limite de 7 Dias da Apple)

> [!NOTE]
> A Apple impõe que aplicações instaladas com uma conta Apple ID gratuita sejam renovadas a cada **7 dias**. A app avisa-te por notificação **24 horas antes** de expirar.

Quando a app expirar ou quando receberes a notificação:
1. Liga o iPhone ao Mac com o cabo.
2. Abre o projeto no Xcode (`GymTracker.xcodeproj`).
3. Confirma que o teu iPhone está selecionado no topo.
4. Prime **`Cmd + R`** (Run).
5. O Xcode renova a assinatura por mais 7 dias.

> [!IMPORTANT]
> **Nunca apagues a app do iPhone para renovar!** Ao compilar pelo Xcode, todos os teus treinos, séries e recordes anteriores continuam 100% salvos.

---

## 📄 Licença

Distribuído sob a licença MIT. Consulta o ficheiro `LICENSE` para mais informações.
