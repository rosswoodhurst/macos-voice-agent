import AVFoundation
import Foundation

struct PCM16AudioBufferFactory: Sendable {
    let sampleRate: Double
    let channelCount: AVAudioChannelCount

    init(sampleRate: Double = 24_000, channelCount: AVAudioChannelCount = 1) {
        self.sampleRate = sampleRate
        self.channelCount = channelCount
    }

    func makeFloatBuffer(fromPCM16 data: Data) throws -> AVAudioPCMBuffer {
        guard data.count >= 2 else {
            throw PCM16AudioBufferFactoryError.emptyAudioData
        }

        guard let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: channelCount,
            interleaved: false
        ) else {
            throw PCM16AudioBufferFactoryError.invalidFormat
        }

        let sampleCount = data.count / 2
        let frames = sampleCount / Int(channelCount)
        guard frames > 0 else {
            throw PCM16AudioBufferFactoryError.emptyAudioData
        }

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frames)
        ) else {
            throw PCM16AudioBufferFactoryError.bufferAllocationFailed
        }

        buffer.frameLength = AVAudioFrameCount(frames)
        guard let channels = buffer.floatChannelData else {
            throw PCM16AudioBufferFactoryError.bufferAllocationFailed
        }

        data.withUnsafeBytes { rawBuffer in
            for frame in 0..<frames {
                for channel in 0..<Int(channelCount) {
                    let sampleIndex = frame * Int(channelCount) + channel
                    let byteOffset = sampleIndex * 2
                    let low = UInt16(rawBuffer[byteOffset])
                    let high = UInt16(rawBuffer[byteOffset + 1]) << 8
                    let sample = Int16(bitPattern: high | low)
                    let normalized = max(-1, min(1, Float(sample) / Float(Int16.max)))
                    channels[channel][frame] = normalized
                }
            }
        }

        return buffer
    }
}

enum PCM16AudioBufferFactoryError: Error, Equatable {
    case emptyAudioData
    case invalidFormat
    case bufferAllocationFailed
}
