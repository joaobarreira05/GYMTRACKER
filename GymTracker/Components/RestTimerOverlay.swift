import SwiftUI

public struct RestTimerOverlay: View {
    @ObservedObject var timerManager = RestTimerManager.shared
    @State private var isExpanded: Bool = false
    
    public var body: some View {
        if timerManager.isPresented {
            VStack(spacing: 0) {
                if isExpanded {
                    expandedView
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                } else {
                    compactPill
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - Compact Floating Pill
    private var compactPill: some View {
        HStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.subheadline.bold())
                .foregroundStyle(.orange)
            
            Text("Rest:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(timerManager.formattedTime)
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .foregroundStyle(timerManager.timeRemaining <= 10 ? .red : .primary)
            
            Spacer()
            
            Button {
                timerManager.addTime(seconds: 15)
                HapticFeedback.light()
            } label: {
                Text("+15s")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }
            
            Button {
                timerManager.togglePause()
                HapticFeedback.light()
            } label: {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .font(.caption.bold())
                    .frame(width: 28, height: 28)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Circle())
            }
            
            Button {
                isExpanded = true
                HapticFeedback.light()
            } label: {
                Image(systemName: "chevron.up")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)
            }
            
            Button {
                timerManager.stop()
                HapticFeedback.light()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        .onTapGesture {
            isExpanded = true
            HapticFeedback.light()
        }
    }
    
    // MARK: - Expanded Modal View
    private var expandedView: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                    Text("Rest Timer")
                        .font(.headline)
                }
                Spacer()
                Button {
                    isExpanded = false
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Countdown Display
            Text(timerManager.formattedTime)
                .font(.system(size: 54, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(timerManager.timeRemaining <= 10 ? .red : .primary)
            
            // Progress Bar
            ProgressView(value: timerManager.progress)
                .tint(timerManager.timeRemaining <= 10 ? .red : .orange)
            
            // Presets
            HStack(spacing: 10) {
                ForEach([60, 90, 120, 180], id: \.self) { seconds in
                    Button {
                        timerManager.start(duration: seconds)
                        HapticFeedback.medium()
                    } label: {
                        Text("\(seconds)s")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(timerManager.initialDuration == seconds ? Color.orange.opacity(0.2) : Color(.tertiarySystemFill))
                            .foregroundStyle(timerManager.initialDuration == seconds ? .orange : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
            
            // Controls (+15s, Play/Pause, -15s, Stop)
            HStack(spacing: 16) {
                Button {
                    timerManager.addTime(seconds: -15)
                    HapticFeedback.light()
                } label: {
                    Label("-15s", systemImage: "gobackward.15")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                
                Button {
                    timerManager.togglePause()
                    HapticFeedback.medium()
                } label: {
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                
                Button {
                    timerManager.addTime(seconds: 15)
                    HapticFeedback.light()
                } label: {
                    Label("+15s", systemImage: "goforward.15")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                
                Button {
                    timerManager.stop()
                    isExpanded = false
                    HapticFeedback.light()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.bold())
                        .padding(12)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Circle())
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
    }
}
