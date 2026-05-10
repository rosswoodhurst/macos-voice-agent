import AVFoundation
import Foundation

struct PCM16AudioConverter: Sendable {
    func pcm16Data(from buffer: AVAudioPCMBuffer) -> Data {
        if let int16ChannelData = buffer.int16ChannelData {
            return pcm16Data(
                channels: int16ChannelData,
                channelCount: Int(buffer.format.channelCount),
                frameLength: Int(buffer.frameLength)
            )
        }

        if let floatChannelData = buffer.floatChannelData {
            return pcm16Data(
                channels: floatChannelData,
                channelCount: Int(buffer.format.channelCount),
                frameLength: Int(buffer.frameLength)
            )
        }

        return Data()
    }

    private func pcm16Data(
        channels: UnsafePointer<UnsafeMutablePointer<Int16>>,
        channelCount: Int,
        frameLength: Int
    ) -> Data {
        guard channelCount > 0, frameLength > 0 else {
            return Data()
        }

        var data = Data()
        data.reserveCapacity(frameLength * MemoryLayout<Int16>.size)

        for frame in 0..<frameLength {
            var mixedSample = 0
            for channel in 0..<channelCount {
                mixedSample += Int(channels[channel][frame])
            }
            appendLittleEndian(Int16(clamping: mixedSample / channelCount), to: &data)
        }

        return data
    }

    private func pcm16Data(
        channels: UnsafePointer<UnsafeMutablePointer<Float>>,
        channelCount: Int,
        frameLength: Int
    ) -> Data {
        guard channelCount > 0, frameLength > 0 else {
            return Data()
        }

        var data = Data()
        data.reserveCapacity(frameLength * MemoryLayout<Int16>.size)

        for frame in 0..<frameLength {
            var mixedSample: Float = 0
            for channel in 0..<channelCount {
                mixedSample += channels[channel][frame]
            }
            let normalized = max(-1, min(1, mixedSample / Float(channelCount)))
            let sample = Int16(normalized * Float(Int16.max))
            appendLittleEndian(sample, to: &data)
        }

        return data
    }

    private func appendLittleEndian(_ sample: Int16, to data: inout Data) {
        var littleEndian = sample.littleEndian
        withUnsafeBytes(of: &littleEndian) { bytes in
            data.append(contentsOf: bytes)
        }
    }
}
