//
//  AKInterpolatedRandomNumberPulse.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka on 9/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** Generates a controlled random number series with interpolation between each new number.

New random numbers are generated at a given frequency between zero and a maximum upper bound.  In between random numbers, the value of this operation is linearly interpolated between the two numbers in time.
*/
@objc class AKInterpolatedRandomNumberPulse : AKParameter {

    // MARK: - Properties

    private var randi = UnsafeMutablePointer<sp_randi>.alloc(1)


    /** Minimum range limit. [Default Value: 0] */
    var lowerBound: AKParameter = akp(0) {
        didSet {
            lowerBound.bind(&randi.memory.min)
            dependencies.append(lowerBound)
        }
    }

    /** Maximum range limit. [Default Value: 1] */
    var upperBound: AKParameter = akp(1) {
        didSet {
            upperBound.bind(&randi.memory.max)
            dependencies.append(upperBound)
        }
    }

    /** Frequency at which the new numbers are generated in Hz. [Default Value: 1] */
    var frequency: AKParameter = akp(1) {
        didSet {
            frequency.bind(&randi.memory.cps)
            dependencies.append(frequency)
        }
    }


    // MARK: - Initializers

    /** Instantiates the pulse with default values
    */
    override init()
    {
        super.init()
        setup()
        dependencies = []
        bindAll()
    }

    /** Instantiates the pulse with all values

    - parameter lowerBound: Minimum range limit. [Default Value: 0]
    - parameter upperBound: Maximum range limit. [Default Value: 1]
    - parameter frequency: Frequency at which the new numbers are generated in Hz. [Default Value: 1]
    */
    convenience init(
        lowerBound minInput: AKParameter,
        upperBound maxInput: AKParameter,
        frequency  cpsInput: AKParameter)
    {
        self.init()

        lowerBound = minInput
        upperBound = maxInput
        frequency  = cpsInput

        bindAll()
    }

    // MARK: - Internals

    /** Bind every property to the internal pulse */
    internal func bindAll() {
        lowerBound.bind(&randi.memory.min)
        upperBound.bind(&randi.memory.max)
        frequency .bind(&randi.memory.cps)
        dependencies.append(lowerBound)
        dependencies.append(upperBound)
        dependencies.append(frequency)
    }

    /** Internal set up function */
    internal func setup() {
        sp_randi_create(&randi)
        sp_randi_init(AKManager.sharedManager.data, randi, 0)
    }

    /** Computation of the next value */
    override func compute() {
        sp_randi_compute(AKManager.sharedManager.data, randi, nil, &leftOutput);
        rightOutput = leftOutput
    }

    /** Release of memory */
    override func teardown() {
        sp_randi_destroy(&randi)
    }
}
