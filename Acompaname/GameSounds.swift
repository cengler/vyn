import AVFoundation

final class GameSounds {
    static let shared = GameSounds()

    var isEnabled = true

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44100
    private lazy var format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.55
        configureAudioSession()
        try? engine.start()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    func playStart() {
        playMelody([
            (523, 0.09, 0.28),
            (659, 0.09, 0.30),
            (784, 0.14, 0.32)
        ])
    }

    func playTap() {
        playMelody([(880, 0.035, 0.18)])
    }

    func playFailure() {
        playMelody([
            (330, 0.10, 0.30),
            (247, 0.16, 0.28)
        ])
    }

    func playSuccess() {
        playMelody([
            (523, 0.07, 0.26),
            (659, 0.07, 0.28),
            (784, 0.11, 0.30)
        ])
    }

    func playVictory() {
        playMelody([
            (523, 0.08, 0.28),
            (659, 0.08, 0.28),
            (784, 0.08, 0.30),
            (988, 0.08, 0.30),
            (784, 0.08, 0.28),
            (988, 0.16, 0.32)
        ])
    }

    private func playMelody(_ notes: [(Double, Double, Float)]) {
        guard isEnabled, let buffer = makeMelodyBuffer(notes: notes) else { return }
        player.scheduleBuffer(buffer, completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    private func makeMelodyBuffer(notes: [(Double, Double, Float)]) -> AVAudioPCMBuffer? {
        let gap = Int(sampleRate * 0.018)
        var samples: [Float] = []

        for (index, note) in notes.enumerated() {
            let noteSamples = makeSamples(frequency: note.0, duration: note.1, volume: note.2)
            samples.append(contentsOf: noteSamples)
            if index < notes.count - 1 {
                samples.append(contentsOf: Array(repeating: 0, count: gap))
            }
        }

        guard !samples.isEmpty,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))
        else { return nil }

        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { pointer in
            guard let base = pointer.baseAddress else { return }
            buffer.floatChannelData?[0].update(from: base, count: samples.count)
        }
        return buffer
    }

    private func makeSamples(frequency: Double, duration: Double, volume: Float) -> [Float] {
        let frameCount = Int(sampleRate * duration)
        guard frameCount > 0 else { return [] }

        let theta = 2 * Double.pi * frequency / sampleRate
        var phase = 0.0
        var samples = [Float]()
        samples.reserveCapacity(frameCount)

        for i in 0..<frameCount {
            let attack = min(1.0, Double(i) / (sampleRate * 0.008))
            let release = max(0, 1.0 - Double(i) / Double(frameCount))
            let envelope = attack * release
            samples.append(Float(sin(phase) * envelope) * volume)
            phase += theta
        }

        return samples
    }
}
