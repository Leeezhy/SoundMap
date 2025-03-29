import Foundation
import AVFoundation
import CoreLocation

class VerticalAudioSound: SynchronouslyGeneratedSound {
    enum VerticalDirection {
        case up
        case down
    }
    
    // MARK: - SoundBase Protocol Properties
    let type: SoundType = .standard
    let layerCount: Int = 1
    
    // MARK: - Properties
    private let direction: VerticalDirection
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
    
    // MARK: - Initialization
    init(direction: VerticalDirection) {
        self.direction = direction
        
        let filename = direction == .up ? "pitch_up" : "pitch_down"
        GDLogAudioInfo("Loading vertical audio file: \(filename).wav")
        
        // Try to find the audio file
        if let url = Bundle.main.url(forResource: filename, withExtension: "wav", subdirectory: "Assets/Sounds/VerticalAudio") {
            GDLogAudioInfo("Found audio file at: \(url.path)")
            do {
                let file = try AVAudioFile(forReading: url)
                GDLogAudioInfo("Audio file format: \(file.processingFormat), length: \(file.length)")
                
                buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                
                guard let buffer = buffer else {
                    GDLogAudioError("Failed to create audio buffer")
                    return
                }
                
                try file.read(into: buffer)
                buffer.frameLength = buffer.frameCapacity
                GDLogAudioInfo("Successfully loaded audio file: \(filename).wav")
            } catch {
                GDLogAudioError("Failed to load vertical audio file: \(error)")
            }
        } else {
            GDLogAudioError("Could not find vertical audio file: \(filename).wav")
            
            // Try to find the file in other possible locations
            let alternativePaths = [
                "Assets/Sounds",
                "Sounds/VerticalAudio",
                "VerticalAudio",
                ""
            ]
            
            for path in alternativePaths {
                if let url = Bundle.main.url(forResource: filename, withExtension: "wav", subdirectory: path) {
                    GDLogAudioInfo("Found audio file in alternative location: \(url.path)")
                    break
                }
            }
        }
    }
    
    // MARK: - SynchronouslyGeneratedSound Protocol
    func generateBuffer(forLayer layer: Int) -> AVAudioPCMBuffer? {
        if buffer == nil {
            GDLogAudioError("No buffer available for playback")
        }
        return buffer
    }
    
    // MARK: - SoundBase Protocol
    func equalizerParams(for layerIndex: Int) -> EQParameters? {
        let gain = SettingsContext.shared.afxGain
        return gain != 0 ? EQParameters(globalGain: gain, parameters: []) : nil
    }
    
    // MARK: - SoundBase Protocol
    
    var is3D: Bool {
        return false
    }
    
    var volume: Float {
        get {
            return 1.0
        }
        set {
            // Volume is not controlled by this implementation
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
        
        // This implementation does not use AVAudioEngine
        GDLogAudioInfo("Successfully prepared vertical audio")
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
} 