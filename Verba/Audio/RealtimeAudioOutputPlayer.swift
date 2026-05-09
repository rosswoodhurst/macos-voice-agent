import AVFoundation
import Foundation

@MainActor
protocol RealtimeAudioOutputPlaying: AnyObject {
    func playPCM16(_ data: Data) throws
    func stop()
}

@MainActor
final class RealtimeAudioOutputPlayer: RealtimeAudioOutputPlaying {
    private let engine: AVAudioEngine
    private let playerNode: AVAudioPlayerNode
    private let bufferFactory: PCM16AudioBufferFactory

    init(
        engine: AVAudioEngine = AVAudioEngine(),
        playerNode: AVAudioPlayerNode = AVAudioPlayerNode(),
        bufferFactory: PCM16AudioBufferFactory = PCM16AudioBufferFactory()
    ) {
        self.engine = engine
        self.playerNode = playerNode
        self.bufferFactory = bufferFactory

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        engine.prepare()
    }

    func playPCM16(_ data: Data) throws {
        let buffer = try bufferFactory.makeFloatBuffer(fromPCM16: data)

        if !engine.isRunning {
            try engine.start()
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    func stop() {
        playerNode.stop()
        engine.stop()
    }
}
