@preconcurrency import AVFoundation
import Foundation

protocol MicrophoneInputCapturing: AnyObject, Sendable {
    func start(onAudioChunk: @escaping @Sendable (Data, Double) -> Void) throws
    func stop()
}

final class MicrophoneInputCapture: MicrophoneInputCapturing, @unchecked Sendable {
    private let engine: AVAudioEngine
    private let outputFormat: AVAudioFormat
    private let pcm16Converter: PCM16AudioConverter
    private let amplitudeMeter: AudioAmplitudeMeter
    private let stateLock = NSLock()
    private var audioConverter: AVAudioConverter?

    init(
        engine: AVAudioEngine = AVAudioEngine(),
        outputSampleRate: Double = 24_000,
        pcm16Converter: PCM16AudioConverter = PCM16AudioConverter(),
        amplitudeMeter: AudioAmplitudeMeter = AudioAmplitudeMeter()
    ) throws {
        guard let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: outputSampleRate,
            channels: 1,
            interleaved: false
        ) else {
            throw MicrophoneInputCaptureError.invalidOutputFormat
        }

        self.engine = engine
        self.outputFormat = outputFormat
        self.pcm16Converter = pcm16Converter
        self.amplitudeMeter = amplitudeMeter
    }

    func start(onAudioChunk: @escaping @Sendable (Data, Double) -> Void) throws {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw MicrophoneInputCaptureError.converterUnavailable
        }

        stateLock.withLock {
            audioConverter = converter
        }

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: inputFormat) { [weak self] buffer, _ in
            guard let self,
                  let convertedBuffer = self.convert(buffer)
            else {
                return
            }

            let pcm16Data = pcm16Converter.pcm16Data(from: convertedBuffer)
            guard !pcm16Data.isEmpty else {
                return
            }

            let level = amplitudeMeter.normalizedRMSLevel(from: convertedBuffer)
            onAudioChunk(pcm16Data, level)
        }

        engine.prepare()
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        stateLock.withLock {
            audioConverter = nil
        }
    }

    private func convert(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        let frameCapacity = AVAudioFrameCount(
            ceil(Double(buffer.frameLength) * outputFormat.sampleRate / buffer.format.sampleRate)
        )
        guard let convertedBuffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: max(frameCapacity, 1)
        ) else {
            return nil
        }

        let inputProvider = AudioConverterInputProvider(buffer: buffer)
        var conversionError: NSError?
        let status = stateLock.withLock {
            audioConverter?.convert(to: convertedBuffer, error: &conversionError) { _, outputStatus in
                inputProvider.nextBuffer(outputStatus: outputStatus)
            }
        }

        guard status != .error, conversionError == nil else {
            return nil
        }

        return convertedBuffer
    }
}

enum MicrophoneInputCaptureError: Error, Equatable {
    case invalidOutputFormat
    case converterUnavailable
}

private final class AudioConverterInputProvider: @unchecked Sendable {
    private let lock = NSLock()
    private var buffer: AVAudioPCMBuffer?

    init(buffer: AVAudioPCMBuffer) {
        self.buffer = buffer
    }

    func nextBuffer(outputStatus: UnsafeMutablePointer<AVAudioConverterInputStatus>) -> AVAudioBuffer? {
        lock.withLock {
            guard let buffer else {
                outputStatus.pointee = .noDataNow
                return nil
            }

            self.buffer = nil
            outputStatus.pointee = .haveData
            return buffer
        }
    }
}
