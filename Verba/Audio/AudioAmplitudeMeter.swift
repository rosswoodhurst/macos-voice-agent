import AVFoundation
import Foundation

struct AudioAmplitudeMeter: Sendable {
    func normalizedRMSLevel(fromPCM16 data: Data) -> Double {
        guard data.count >= 2 else {
            return 0
        }

        let sampleCount = data.count / 2
        var sumSquares = 0.0

        data.withUnsafeBytes { rawBuffer in
            for index in 0..<sampleCount {
                let byteOffset = index * 2
                let low = UInt16(rawBuffer[byteOffset])
                let high = UInt16(rawBuffer[byteOffset + 1]) << 8
                let sample = Int16(bitPattern: high | low)
                let normalized = Double(sample) / Double(Int16.max)
                sumSquares += normalized * normalized
            }
        }

        return min(max(sqrt(sumSquares / Double(sampleCount)), 0), 1)
    }

    func normalizedRMSLevel(from buffer: AVAudioPCMBuffer) -> Double {
        if let floatChannelData = buffer.floatChannelData {
            return normalizedRMSLevel(
                channels: floatChannelData,
                channelCount: Int(buffer.format.channelCount),
                frameLength: Int(buffer.frameLength)
            )
        }

        if let int16ChannelData = buffer.int16ChannelData {
            return normalizedRMSLevel(
                channels: int16ChannelData,
                channelCount: Int(buffer.format.channelCount),
                frameLength: Int(buffer.frameLength)
            )
        }

        return 0
    }

    private func normalizedRMSLevel(
        channels: UnsafePointer<UnsafeMutablePointer<Float>>,
        channelCount: Int,
        frameLength: Int
    ) -> Double {
        guard channelCount > 0, frameLength > 0 else {
            return 0
        }

        var sumSquares = 0.0
        for channel in 0..<channelCount {
            let samples = channels[channel]
            for frame in 0..<frameLength {
                let value = Double(samples[frame])
                sumSquares += value * value
            }
        }

        let count = Double(channelCount * frameLength)
        return min(max(sqrt(sumSquares / count), 0), 1)
    }

    private func normalizedRMSLevel(
        channels: UnsafePointer<UnsafeMutablePointer<Int16>>,
        channelCount: Int,
        frameLength: Int
    ) -> Double {
        guard channelCount > 0, frameLength > 0 else {
            return 0
        }

        var sumSquares = 0.0
        for channel in 0..<channelCount {
            let samples = channels[channel]
            for frame in 0..<frameLength {
                let value = Double(samples[frame]) / Double(Int16.max)
                sumSquares += value * value
            }
        }

        let count = Double(channelCount * frameLength)
        return min(max(sqrt(sumSquares / count), 0), 1)
    }
}
