import UIKit
import CoreMotion
import AudioToolbox

class popupViewController: UIViewController {
    
    @IBOutlet weak var xAccel: UITextField!
    @IBOutlet weak var yAccel: UITextField!
    @IBOutlet weak var zAccel: UITextField!
    
    @IBOutlet weak var xGyro: UITextField!
    @IBOutlet weak var yGyro: UITextField!
    @IBOutlet weak var zGyro: UITextField!
    
    var motionManager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        myAccelerometer()
        myGyroscope()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func myAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data,error) in
            if let trueData = data{
                self.view.reloadInputViews()
                let x = trueData.acceleration.x
                let y = trueData.acceleration.y
                let z = trueData.acceleration.z
                self.xAccel.text = "x: \(Double(x).rounded(toPlaces: 3))"
                self.yAccel.text = "y: \(Double(y).rounded(toPlaces: 3))"
                self.zAccel.text = "z: \(Double(z).rounded(toPlaces: 3))"
            }
        }
    }
    func myGyroscope(){
        motionManager.gyroUpdateInterval = 1.0 / 60.0
        motionManager.startGyroUpdates(to: OperationQueue.current!){ (data, error) in
            if let trueData = data {
                let x = trueData.rotationRate.x * 2 * Double.pi
                let y = trueData.rotationRate.y * 2 * Double.pi
                let z = trueData.rotationRate.z * 2 * Double.pi
                self.xGyro.text = "x: \(Double(x).rounded(toPlaces: 3))"
                self.yGyro.text = "y: \(Double(y).rounded(toPlaces: 3))"
                self.zGyro.text = "z: \(Double(z).rounded(toPlaces: 3))"
                
            }
        }
    }
    
    @IBAction func backtoHome(_ sender: Any) {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
}
