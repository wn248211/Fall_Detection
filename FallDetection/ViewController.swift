import UIKit
import CoreMotion
import AudioToolbox

class ViewController: UIViewController {

    var timer: Timer!
    var counter:Int = 10
    var alertController: UIAlertController!
    var alertControllerMessageSent: UIAlertController!
    var iamFine = false
    var acceDetected = false
    var gyroDetected = false
    
    @IBOutlet weak var fallLabel: UILabel!
    
    var motionManager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startDetection(_ sender: Any) {
        self.fallLabel.text = "Monitoring"
        
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0 // 60 Hz
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data,error) in
            if let myData = data{
                
                let x = myData.acceleration.x
                let y = myData.acceleration.y
                let z = myData.acceleration.z
                
                //SVM
                let SVM = sqrt((x * x) + (y * y) + (z * z))

                print ("SVM: \(SVM)")
                
                //A fall impact will be identified if SVM is greater than 6G
                if (SVM > 6){
                    self.motionManager.stopAccelerometerUpdates()
                    self.acceDetected = true
                }
                
                if(self.acceDetected == true && self.gyroDetected == true){
                    self.fallLabel.text = "Fall Detected"
                    AudioServicesPlaySystemSound(4095)
                    AudioServicesPlaySystemSound(1005)
                    self.iamFine = false
                    self.acceDetected = false
                    self.gyroDetected = false
                    self.counter = 10
                    self.showAlert()
                }
            }
        }
        
        motionManager.gyroUpdateInterval = 1.0 / 60.0 //60 Hz
        motionManager.startGyroUpdates(to: OperationQueue.current!){ (data, error) in
            if let myData = data {
                let x = myData.rotationRate.x * 2 * Double.pi
                let y = myData.rotationRate.y * 2 * Double.pi
                let z = myData.rotationRate.z * 2 * Double.pi
                
                //gyroscope square root of y and z
                let GS = sqrt((x * x) + (y * y) + (z * z))
                
                print ("GS: \(Double(GS).rounded(toPlaces: 3))")
                
                
                if (GS > 90){
                    self.motionManager.stopGyroUpdates()
                    self.gyroDetected = true
                }
                
                if(self.acceDetected == true && self.gyroDetected == true){
                    self.fallLabel.text = "Fall Detected"
                    AudioServicesPlaySystemSound(4095)
                    AudioServicesPlaySystemSound(1005)
                    self.iamFine = false
                    self.acceDetected = false
                    self.gyroDetected = false
                    self.counter = 10
                    self.showAlert()
                }
            }
            
        }
    }
    
    //alert
    func showAlert(){
        alertController = UIAlertController(title: "Are you ok?", message: countDownString(), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "I am fine", style: UIAlertActionStyle.default, handler: { (action) in
            self.alertController.dismiss(animated: true, completion: nil)
            print ("fine")
            self.iamFine = true
            self.timer!.invalidate()
        }))
        
        present(alertController, animated: true){
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.decrease), userInfo: nil, repeats: true)
        }
    }
    
    func countDownString() -> String {
        return "\(counter) seconds"
    }
    
    @objc func decrease(){
        var seconds: Int
        if(self.iamFine == false){
            if(counter > 0) {
                self.counter = self.counter - 1
                seconds = (counter % 3600) % 60
                alertController.message = String(seconds) + " seconds"
                print("\(seconds)")  // Correct value in console
            }
            else{
                dismiss(animated: true, completion: nil)
                
                //disable the countdown timer
                timer!.invalidate()
                sleep(1)
                //new viewController to show message sent
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "isFallenPopUp") as! isFallenPopUp
                present(nextViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func stopDetection(_ sender: Any) {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        self.fallLabel.text = "Stopped"
    }
}

extension Double{
    func rounded(toPlaces places:Int) -> Double{
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
