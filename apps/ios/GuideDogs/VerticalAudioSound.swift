import Foundation
import CoreLocation
import AVFoundation

class VerticalAudioSound: SynchronouslyGeneratedSound {
    enum VerticalDirection {
        case up
        case down
    }
    
    let type: SoundType
    let direction: VerticalDirection
    let layerCount: Int = 1
    private var buffer: AVAudioPCMBuffer?
    
    var description: String {
        return "VerticalAudioSound(\(direction))"
    }
    
    var duration: TimeInterval? {
        guard let buffer = buffer else {
            return nil
        }
        
        let frames = buffer.frameLength
        let sampleRate = buffer.format.sampleRate
        
        return Double(frames) / sampleRate
    }
    
    init(direction: VerticalDirection) {
        self.direction = direction
        self.type = .standard
        
        let filename = direction == .up ? "pitch_up" : "pitch_down"
        GDLogAudioInfo("Attempting to load vertical audio file: \(filename)")
        
        // Try to load from main bundle
        if let url = Bundle.main.url(forResource: filename, withExtension: "wav") {
            GDLogAudioInfo("Found audio file in main bundle: \(url.path)")
            loadAudioFile(from: url)
        } else {
            GDLogAudioError("Could not find audio file in main bundle")
        }
    }
    
    private func loadAudioFile(from url: URL) {
        GDLogAudioInfo("Loading audio file from: \(url.path)")
        
        do {
            let file = try AVAudioFile(forReading: url)
            GDLogAudioInfo("Successfully opened audio file with format: \(file.processingFormat)")
            
            buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
            guard let buffer = buffer else {
                GDLogAudioError("Failed to create audio buffer")
                return
            }
            
            try file.read(into: buffer)
            buffer.frameLength = buffer.frameCapacity
            
            GDLogAudioInfo("Successfully loaded audio file with \(buffer.frameLength) frames")
        } catch {
            GDLogAudioError("Failed to load audio file: \(error)")
        }
    }
    
    func generateBuffer(forLayer: Int) -> AVAudioPCMBuffer? {
        if buffer == nil {
            GDLogAudioError("No buffer available for playback")
        } else {
            GDLogAudioInfo("Generating buffer with \(buffer?.frameLength ?? 0) frames")
        }
        return buffer
    }
    
    // MARK: - SoundBase Protocol
    
    var is3D: Bool {
        return false
    }
    
    var volume: Float {
        get {
            return SettingsContext.shared.otherVolume
        }
        set {
            // Volume is controlled by SettingsContext
        }
    }
    
    var isPlaying: Bool {
        return false
    }
    
    var state: AudioPlayerState {
        return .notPrepared
    }
    
    var connectionState: AudioPlayerConnectionState {
        return .notConnected
    }
    
    func prepare(engine: AVAudioEngine, completion: ((Bool) -> Void)?) {
        GDLogAudioInfo("Preparing vertical audio for playback")
        
        guard let buffer = buffer else {
            GDLogAudioError("No buffer available for preparation")
            completion?(false)
            return
        }
        
        GDLogAudioInfo("Successfully prepared vertical audio with \(buffer.frameLength) frames")
        completion?(true)
    }
    
    func updateConnectionState(_ state: AudioPlayerConnectionState) {
        // This implementation does not use connection state
    }
    
    func play(_ userHeading: Heading?, _ userLocation: CLLocation?) throws {
        GDLogAudioInfo("Attempting to play vertical audio: \(direction)")
        // This implementation does not use userHeading or userLocation
    }
    
    func resumeIfNecessary() throws -> Bool {
        return false
    }
    
    func stop() {
        GDLogAudioInfo("Stopping vertical audio")
    }
    
    func equalizerParams(for layerIndex: Int) -> EQParameters? {
        let gain = SettingsContext.shared.afxGain
        return gain != 0 ? EQParameters(globalGain: gain, parameters: []) : nil
    }
}
