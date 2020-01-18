//
//  FlightHubViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 3/7/18.
//  Copyright © 2018 DJI. All rights reserved.
//

import DJISDK
import UIKit


class FlightHubViewController: UIViewController, DJIFlightHubManagerDelegate {
    @IBOutlet weak var djiAccountStatusLabel: UILabel!
    @IBOutlet weak var flightHubAuthorizationLabel: UILabel!
    @IBOutlet weak var flightHubInformationTextView: UITextView!
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var activateBtn: UIButton!
    var dataUploadingEnabled = false
    
    func showAlert(_ msg: String?) {
        // create the alert
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func flightHubManager(_ flightHubManager: DJIFlightHubManager, didUpdate state: DJIFlightHubUploadState, error: Error?) {
        if state == .notLoggedIn  {
            self.updateAccountUI(isLogin: false)
            self.loginToAccount(completionHandler: { [unowned self] (success:Bool) in
                if (success) {
                    self.updateAccountUI(isLogin: true)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if DJISDKManager.flightHubManager()?.isUserActivated == false {
            self.updateAuthorizationUI(isAuthorization: false)
            let currentState = DJISDKManager.userAccountManager().userAccountState
            if currentState == .notLoggedIn || currentState == .tokenOutOfDate {
                self.updateAccountUI(isLogin: false)
                self.loginToAccount(completionHandler: { (success:Bool) in
                    if success {
                        self.updateAccountUI(isLogin: true)
                    } else {
                        print("Failed to login to account")
                    }
                })
            } else {
                self.updateAccountUI(isLogin: true)
            }
        } else {
            DJISDKManager.flightHubManager()?.delegate = self
            self.updateAuthorizationUI(isAuthorization: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func loginToAccount(completionHandler: @escaping (Bool) -> ()) {
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false, withCompletion: { (state:DJIUserAccountState?, error:Error?)in
            if error != nil{
                print("\(String(describing: error))")
                completionHandler(false)
            }
            completionHandler(true)
        })
    }
    
    private func logoutAccount(completionHandler: @escaping (Bool) -> ()) {
        
        DJISDKManager.userAccountManager().logOutOfDJIUserAccount(completion: { ( error:Error?)in
            if error != nil{
                print("\(String(describing: error))")
                completionHandler(false)
            }
            completionHandler(true)
        })
        
    }
    
    private func updateAccountUI (isLogin: Bool) {
        if (isLogin) {
            self.djiAccountStatusLabel.text = "Logged In"
            self.activateBtn.isEnabled = true
        } else {
            self.djiAccountStatusLabel.text = "Logged Out"
            self.activateBtn.isEnabled = false
        }
    }
    
    private func updateAuthorizationUI (isAuthorization: Bool) {
        if (isAuthorization) {
            self.flightHubAuthorizationLabel.text = "Authorized"
            self.flightHubInformationTextView.isHidden = false
            self.rightStackView.isHidden = false
            self.middleStackView.isHidden = false
            self.leftStackView.isHidden = false
        } else {
            self.flightHubAuthorizationLabel.text = "Not Authorized"
            self.flightHubInformationTextView.isHidden = true
            self.rightStackView.isHidden = true
            self.middleStackView.isHidden = true
            self.leftStackView.isHidden = true
        }
    }
    
    private func getUploadStateString(state:DJIFlightHubUploadState) -> String {
        switch state {
            case .disabled:
                return "Disabled"
            case .rejectedByServer:
                return "Rejected by server."
            case .notLoggedIn:
                return "Not logged in."
            case .networkNotReachable:
                return "Network not reachable."
            case .aircraftDisconnected:
                return "Aircraft disconnected."
            case .readyToUpload:
                return "Ready to upload."
            case .uploading:
                return "Uploading."
            default:
                break
        }
        return "Unknown."
    }
    
    @IBAction func onBindAircraftButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Bind Aircraft?", message: "Would you like to bind the connected aircraft to the authorized FlightHub account?", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [unowned self] action in
            //Get the teamID by hitting the Team Info Button which will print to the console
            DJISDKManager.flightHubManager()?.bindAircraft(toTeam: alert.textFields![0].text!, withCompletion: { (error: Error?) in
                guard error == nil else {
                    self.flightHubInformationTextView.text = "Bind Aircraft failed with error: \(String(describing: error))"
                    return
                }
                self.flightHubInformationTextView.text = "Binding Aircraft succeeded."
            })
        }))
        alert.addTextField { textField in
            textField.placeholder = "TeamID:"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onUnbindAircraftButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Unbind Aircraft?", message: "Would you like to unbind the connected aircraft?", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [unowned self] action in
            DJISDKManager.flightHubManager()?.unbindAircraft(completion: { (error: Error?) in
                guard error == nil else {
                    self.flightHubInformationTextView.text = "Unbind Aircraft failed with error: \(String(describing: error))"
                    return
                }
                self.flightHubInformationTextView.text = "Unbind Aircraft Succeeded."
            });
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onGetTeamInfoPressed(_ sender: Any) {
        DJISDKManager.flightHubManager()?.getTeamsInformation(completion: { [unowned self] (teams:[DJIFlightHubTeam]?, error: Error?) in
            guard error == nil  && teams != nil else {
                self.flightHubInformationTextView.text = "Get team info failed with error: \(String(describing: error))"
                return
            }
            var resultString = "Data:"
            for team in teams! {
                resultString += " teamID:\(team.teamID), groupID:\(team.groupID), name:\(team.name)\n"
                for device in team.devices {
                    resultString += "Serial Number:\(device.sn), Type:\(device.model), Name:\(device.name)\n"
                    resultString += "******************************\n"
                }
                for user in team.members {
                    resultString += "Account:\(user.account), name:\(user.nickName), role:\(user.role)"
                    resultString += "******************************\n"
                }
                resultString += "--------------------------------\n"
            }
            self.flightHubInformationTextView.text = resultString
        })
    }
    
    @IBAction func onGetStatisticsPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Historical Data?", message: "Would you like to get the historical data for the following time period?", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [unowned self] action in
            let startTime = alert.textFields![0].text!
            let endTime = alert.textFields![1].text!
            let account = alert.textFields![2].text!
            let teamID = alert.textFields![3].text!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM//dd"
            let startDate = dateFormatter.date(from: startTime)
            let startTimeInterval = startDate?.timeIntervalSince1970
            let endDate = dateFormatter.date(from: endTime)
            let endTimeInterval = endDate?.timeIntervalSince1970
            
            DJISDKManager.flightHubManager()?.getFlightStatistics(withStartTime: startTimeInterval! * 1000 , endTime: endTimeInterval! * 1000, account: account, teamID: teamID, withCompletion: { (flight:DJIFlightHubHistoricalFlight?, error:Error?) in
                guard error == nil && flight != nil else {
                    print("There was an error getting the flight information: \(String(describing: error))")
                    return
                }
                var resultString = "Historical Flight Data"
                resultString += "Total Duration:\(flight!.statistics.totalDuration), Average Duration:\(flight!.statistics.averageDuration), Duration Distribution:\(flight!.statistics.durationDistribution)\n"
                resultString += "*********HistoricalDetail***********\n"
                for detail in flight!.history {
                    resultString += "Order ID:\(detail.orderID), Serial Number:\(detail.sn), Device: \(detail.deviceModel), Team ID:\(detail.teamID), Account:\(detail.account), Address:\(detail.address), Start Time:\(detail.startTime), Contact:\(detail.contact), MaxFlightTime: \(detail.maxFlightTime), MinFlightTime: \(detail.minFlightTime), Distance: \(detail.distance), Duration: \(detail.duration), Peak Height: \(detail.peakHeight)\n"
                    
                }
                resultString += "******************************\n"
                self.flightHubInformationTextView.text = resultString
            })
            
        }))
        alert.addTextField { textField in
            textField.placeholder = "StartTime (yyyy/MM/dd)"
        }
        alert.addTextField { textField in
            textField.placeholder = "EndTime (yyyy/MM/dd)"
        }
        alert.addTextField { textField in
            textField.placeholder = "Account"
        }
        alert.addTextField { textField in
            textField.placeholder = "TeamID"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        
        self.loginToAccount(completionHandler: { [unowned self] (success:Bool) in
            if (success) {
                self.updateAccountUI(isLogin: true)
            }
        })
    }
    
    @IBAction func logoutBtnAction(_ sender: Any) {
        
        self.logoutAccount(completionHandler: { [unowned self] (success:Bool) in
            if (success) {
                self.updateAccountUI(isLogin: false)
            }
        })
        
    }
    
    @IBAction func activateAccount(_ sender: Any) {
        
        DJISDKManager.flightHubManager()?.updateActivationState(completion: { [unowned self] (error: Error?) in
            guard error == nil else {
                self.showAlert(error.debugDescription)
                self.updateAuthorizationUI(isAuthorization: false)
                return
            }
            DJISDKManager.flightHubManager()?.delegate = self
            self.updateAuthorizationUI(isAuthorization: true)
        })
    }
    
    @IBAction func onGetStreamSourcePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Get Source?", message: "Would you like to get the stream address from the following product?", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [unowned self] action in
            DJISDKManager.flightHubManager()?.getLiveViewStreamSource(withSN: alert.textFields![0].text!, withCompletion: { (stream:DJIFlightHubLiveStream?, error:Error?) in
                guard error != nil && stream != nil else {
                    print("Get liveStream failed with error:\(String(describing:error))")
                    return
                }
                var resultString = "Data: rtmp:\(stream!.rtmpURL), isValid:\(stream!.isValid)\n"
                resultString += "******************************\n"
                self.flightHubInformationTextView.text = resultString
            })
        }))
        alert.addTextField { textField in
            textField.placeholder = "Serial Number:"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onGetStreamingDevicesPressed(_ sender: Any) {
        DJISDKManager.flightHubManager()?.getStreamingDevices(completion: { (devices:[DJIFlightHubOnlineDevice]?, error:Error?) in
            guard error == nil && devices != nil else {
                print("Error getting the streaming devices or there were none:\(String(describing:error))")
                return
            }
            var resultString = "Data:"
            for device in devices! {
                resultString += "Serial Number:\(device.sn), TeamID:\(device.teamID)\n"
                resultString += "******************************\n"
            }
            self.flightHubAuthorizationLabel.text = resultString
        })
    }
    
    @IBAction func onGetStreamingDestinationPressed(_ sender: Any) {
        DJISDKManager.flightHubManager()?.getLiveViewStreamDestination(completion: { (upStream: DJIFlightHubUpStream?, error:Error?) in
            guard error == nil && upStream != nil else {
                print("There was an error getting the livestream destination")
                return
            }
            var resultString = "Data: rtmp:\(upStream!.rtmpURL)\n"
            resultString += "******************************\n"
        })
    }
    
    @IBAction func onGetLivestreamStabilityPressed(_ sender: Any) {
        DJISDKManager.flightHubManager()?.checkIfLiveStreamStable(completion: { (result: Bool, error:Error?) in
            guard error == nil else {
                print("Check livestream state failed with error:\(String(describing: error))")
                return
            }
            if (result) {
                print("Stable")
            } else {
                print("Not stable")
            }
        })
    }
    
    @IBAction func onGetOnlineDevicesPressed(_ sender: Any) {
        DJISDKManager.flightHubManager()?.getOnlineDevices(completion: { (devices:[DJIFlightHubOnlineDevice]?, error:Error?) in
            guard error == nil && devices != nil else {
                print("Error getting the online devices:\(String(describing:error))")
                return
            }
            var resultString = "Data:"
            for device in devices! {
                resultString += "Serial Number:\(device.sn), TeamID:\(device.teamID)\n"
                resultString += "******************************\n"
            }
            self.flightHubAuthorizationLabel.text = resultString
        })
    }
    
    @IBOutlet weak var enableButton: UIButton!
    @IBAction func onEnableUploadPressed(_ sender: Any) {
        var titleString:String
        var descriptionString:String
        if dataUploadingEnabled {
            titleString = "Disable Uploading"
            descriptionString = "Would you like to disable data uploading?"
        } else {
            titleString = "Enable Uploading"
            descriptionString = "Would you like to enable data uploading?"
        }
        let alert = UIAlertController(title: titleString, message: descriptionString, preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [unowned self] action in
            self.dataUploadingEnabled = !self.dataUploadingEnabled
            DJISDKManager.flightHubManager()?.setUploadEnabled(self.dataUploadingEnabled)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onUploadTimePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Upload Time Interval", message: "Change the interval at which the ", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Interval Time [1-10]:"
        }
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [unowned self] action in
            guard alert.textFields![0].text != nil else {
                print("Please enter a value between 1 and 10.")
                return
            }
            if let interval = Double(alert.textFields![0].text!) {
                let error = DJISDKManager.flightHubManager()?.setUploadTimeInterval(interval)
                if error != nil {
                    print("Set upload interval failed with error:\(String(describing: error))")
                } else {
                    if let uploadState = DJISDKManager.flightHubManager()?.uploadState {
                        var text = self.getUploadStateString(state: uploadState)
                        text += ",uploadTimeInterval = \(DJISDKManager.flightHubManager()?.uploadTimeInterval ?? 5)"
                        text += " isUserActivated = \(DJISDKManager.flightHubManager()?.isUserActivated ?? false)"
                        self.flightHubInformationTextView.text = text
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onGetFlighPathPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Upload Time Interval", message: "Change the interval at which the ", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { textField in
            textField.placeholder = "OrderID: (Get from DJIFlightHubFlightHistoricalDetail)"
        }
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [unowned self] action in
            guard alert.textFields![0].text != nil else {
                print("Please enter an OrderID.")
                return
            }
    
            DJISDKManager.flightHubManager()?.getHistoricalFlightPath(alert.textFields![0].text, withCompletion: { (flightPath:[DJIFlightHubFlightPathNode]?, error:Error?) in
                guard error == nil && flightPath != nil else {
                    print("There was an error getting the flight data: \(String(describing:error))")
                    return;
                }
                var flightDataString = "Data:"
                for pathNode in flightPath! {
                    flightDataString += "date:\(pathNode.date), device:\(pathNode.deviceModel), flightTime:\(pathNode.flightTime), altitude:\(pathNode.altitude), latitude:\(pathNode.coordinate.latitude). longitude:\(pathNode.coordinate.longitude), speed:\(pathNode.speed), yaw:\(pathNode.yaw)\n"
                    flightDataString += "******************************\n"
                }
                self.flightHubInformationTextView.text = flightDataString
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
