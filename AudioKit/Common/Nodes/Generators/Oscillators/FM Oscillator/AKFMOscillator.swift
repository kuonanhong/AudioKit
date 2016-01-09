//
//  AKFMOscillator.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Classic FM Synthesis audio generation.
///
/// - parameter baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
/// - parameter carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
/// - parameter modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
/// - parameter modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
/// - parameter amplitude: Output Amplitude.
///
public class AKFMOscillator: AKVoice {

    // MARK: - Properties

    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()

    internal var internalAU: AKFMOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var baseFrequencyParameter: AUParameter?
    private var carrierMultiplierParameter: AUParameter?
    private var modulatingMultiplierParameter: AUParameter?
    private var modulationIndexParameter: AUParameter?
    private var amplitudeParameter: AUParameter?

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    public var baseFrequency: Double = 440 {
        didSet {
            baseFrequencyParameter?.setValue(Float(baseFrequency), originator: token!)
        }
    }
    /// This multiplied by the baseFrequency gives the carrier frequency.
    public var carrierMultiplier: Double = 1.0 {
        didSet {
            carrierMultiplierParameter?.setValue(Float(carrierMultiplier), originator: token!)
        }
    }
    /// This multiplied by the baseFrequency gives the modulating frequency.
    public var modulatingMultiplier: Double = 1 {
        didSet {
            modulatingMultiplierParameter?.setValue(Float(modulatingMultiplier), originator: token!)
        }
    }
    /// This multiplied by the modulating frequency gives the modulation amplitude.
    public var modulationIndex: Double = 1 {
        didSet {
            modulationIndexParameter?.setValue(Float(modulationIndex), originator: token!)
        }
    }
    /// Output Amplitude.
    public var amplitude: Double = 1 {
        didSet {
            amplitudeParameter?.setValue(Float(amplitude), originator: token!)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - parameter baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    /// - parameter carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    /// - parameter modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    /// - parameter modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    /// - parameter amplitude: Output Amplitude.
    ///
    public init(
        table: AKTable = AKTable(.Sine),
        baseFrequency: Double = 440,
        carrierMultiplier: Double = 1.0,
        modulatingMultiplier: Double = 1,
        modulationIndex: Double = 1,
        amplitude: Double = 1) {

        self.baseFrequency = baseFrequency
        self.carrierMultiplier = carrierMultiplier
        self.modulatingMultiplier = modulatingMultiplier
        self.modulationIndex = modulationIndex
        self.amplitude = amplitude

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x666f7363 /*'fosc'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKFMOscillatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKFMOscillator",
            version: UInt32.max)

        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKFMOscillatorAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            self.internalAU?.setupTable(Int32(table.size))
            for var i = 0; i < table.size; i++ {
                self.internalAU?.setTableValue(table.values[i], atIndex: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        baseFrequencyParameter        = tree.valueForKey("baseFrequency")        as? AUParameter
        carrierMultiplierParameter    = tree.valueForKey("carrierMultiplier")    as? AUParameter
        modulatingMultiplierParameter = tree.valueForKey("modulatingMultiplier") as? AUParameter
        modulationIndexParameter      = tree.valueForKey("modulationIndex")      as? AUParameter
        amplitudeParameter            = tree.valueForKey("amplitude")            as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.baseFrequencyParameter!.address {
                    self.baseFrequency = Double(value)
                } else if address == self.carrierMultiplierParameter!.address {
                    self.carrierMultiplier = Double(value)
                } else if address == self.modulatingMultiplierParameter!.address {
                    self.modulatingMultiplier = Double(value)
                } else if address == self.modulationIndexParameter!.address {
                    self.modulationIndex = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        }
        baseFrequencyParameter?.setValue(Float(baseFrequency), originator: token!)
        carrierMultiplierParameter?.setValue(Float(carrierMultiplier), originator: token!)
        modulatingMultiplierParameter?.setValue(Float(modulatingMultiplier), originator: token!)
        modulationIndexParameter?.setValue(Float(modulationIndex), originator: token!)
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public func copy() -> AKVoice {
        let copy = AKFMOscillator(baseFrequency: self.baseFrequency, carrierMultiplier: self.carrierMultiplier, modulatingMultiplier: self.modulatingMultiplier, modulationIndex: self.modulationIndex, amplitude: self.amplitude)
        return copy
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}