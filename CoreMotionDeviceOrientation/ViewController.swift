//
//  ViewController.swift
//  CoreMotionDeviceOrientation
//
//  Created by Rizal Hilman on 13/11/20.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private var deviceOrientation: UIDeviceOrientation = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        motionManager.accelerometerUpdateInterval = 1.0
        motionManager.deviceMotionUpdateInterval = 1.0
        motionManager.gyroUpdateInterval = 1.0
        motionManager.magnetometerUpdateInterval = 1.0
        
        // Start the measuring
        startMeasuring()
    }

    
    func startMeasuring() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] (accelerometerData, error) in
            
            guard let strongSelf = self else {
                return
            }
            guard let accelerometerData = accelerometerData else {
                return
            }

            let acceleration = accelerometerData.acceleration
            let xx = -acceleration.x
            let yy = acceleration.y
            let z = acceleration.z
            let angle = atan2(yy, xx)
            var deviceOrientation = strongSelf.deviceOrientation
            let absoluteZ = fabs(z)

            if deviceOrientation == .faceUp || deviceOrientation == .faceDown {
                if absoluteZ < 0.845 {
                    if angle < -2.6 {
                        deviceOrientation = .landscapeRight
                        strongSelf.updateLabel(text: "Lanscape Right")
                    } else if angle > -2.05 && angle < -1.1 {
                        deviceOrientation = .portrait
                        strongSelf.updateLabel(text: "Portrait")
                    } else if angle > -0.48 && angle < 0.48 {
                        deviceOrientation = .landscapeLeft
                        strongSelf.updateLabel(text: "Lanscape Left")
                    } else if angle > 1.08 && angle < 2.08 {
                        deviceOrientation = .portraitUpsideDown
                        strongSelf.updateLabel(text: "Portrait Upside Down")
                    }
                } else if z < 0 {
                    deviceOrientation = .faceUp
                    strongSelf.updateLabel(text: "Face Up")
                } else if z > 0 {
                    deviceOrientation = .faceDown
                    strongSelf.updateLabel(text: "Face Down")
                }
            } else {
                if z > 0.875 {
                    deviceOrientation = .faceDown
                    strongSelf.updateLabel(text: "Face Down")
                } else if z < -0.875 {
                    deviceOrientation = .faceUp
                    strongSelf.updateLabel(text: "Face Up")
                } else {
                    switch deviceOrientation {
                    case .landscapeLeft:
                        if angle < -1.07 {
                            deviceOrientation = .portrait
                            strongSelf.updateLabel(text: "Portrait")
                        }
                        if angle > 1.08 {
                            deviceOrientation = .portraitUpsideDown
                            strongSelf.updateLabel(text: "Portrait Upside Down")
                        }
                    case .landscapeRight:
                        if angle < 0 && angle > -2.05 {
                            deviceOrientation = .portrait
                            strongSelf.updateLabel(text: "Portrait")
                        }
                        if angle > 0 && angle < 2.05 {
                            deviceOrientation = .portraitUpsideDown
                            strongSelf.updateLabel(text: "Portrait Upside Down")
                        }
                    case .portraitUpsideDown:
                        if angle > 2.66 {
                            deviceOrientation = .landscapeRight
                            strongSelf.updateLabel(text: "Landscape Right")
                        }
                        if angle < 0.48 {
                            deviceOrientation = .landscapeLeft
                            strongSelf.updateLabel(text: "Landscape Left")
                        }
                    case .portrait:
                        if angle > -0.47 {
                            deviceOrientation = .landscapeLeft
                            strongSelf.updateLabel(text: "Landscape Left")
                        }
                        if angle < -2.64 {
                            deviceOrientation = .landscapeRight
                            strongSelf.updateLabel(text: "Landscape Right")
                        }
                    default:
                        if angle > -0.47 {
                            deviceOrientation = .landscapeLeft
                            strongSelf.updateLabel(text: "Landscape Left")
                        }
                        if angle < -2.64 {
                            deviceOrientation = .landscapeRight
                            strongSelf.updateLabel(text: "Landscape Right")
                        }
                    }
                }
            }

            // Print Raw Orientation
            print(deviceOrientation.rawValue)
        }
    }

    func stopMeasuring() {
        motionManager.stopAccelerometerUpdates()
    }

    func currentInterfaceOrientation() -> AVCaptureVideoOrientation {
        switch deviceOrientation {
        case .portrait:
            return .portrait
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    func updateLabel(text: String) {
        DispatchQueue.main.async {
            self.label.text = text
        }
    }
}

