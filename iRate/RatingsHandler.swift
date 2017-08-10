//
//  RatingsHandler.swift
//  Parents
//
//  Created by Yousra Kamoona on 6/1/15.
//  Copyright (c) 2015 Edmodo. All rights reserved.
//

import Foundation
import EDMPlatform
import EDMixpanel
import MessageUI

enum RatingsKey : String
{
    case ShouldBlockPromptOnLaunch = "ShouldBlockPromptOnLaunch"
    case NumOfUses = "NumOfUsesSince-v1.6.0"
}

open class RatingsHandler : NSObject
{
    static let sharedInstance = RatingsHandler()
    
    let useCountForRatingsPrompt: Int = 3

    fileprivate override init()
    {
        super.init()
    }
    
    open func setup(messageTitle title:String)
    {
        self.configureiRate(title)
    }
    
    fileprivate func configureiRate(_ messageTitle:String)
    {
        //configure iRate
        iRate.sharedInstance().eventsUntilPrompt = 0
        iRate.sharedInstance().usesUntilPrompt = 0 // total num of launches since installation
        iRate.sharedInstance().daysUntilPrompt = 3
        iRate.sharedInstance().remindPeriod = 7
        iRate.sharedInstance().promptAtLaunch = false
        
        iRate.sharedInstance().delegate = self

        if (debugBuild)
        {
           iRate.sharedInstance().onlyPromptIfLatestVersion = false
        }
        
        //overriding the default iRate strings
        iRate.sharedInstance().messageTitle = NSLocalizedString(messageTitle, comment: "iRate message title")
        iRate.sharedInstance().message = NSLocalizedString("Rate it now in the App Store!", comment: "iRate message")
        iRate.sharedInstance().cancelButtonLabel = NSLocalizedString("No Thanks", comment: "iRate decline button")
        iRate.sharedInstance().remindButtonLabel = NSLocalizedString("Remind Me Later", comment: "iRate remind button")
        iRate.sharedInstance().rateButtonLabel = NSLocalizedString("Rate Now", comment: "iRate accept button")
    }
}

// MARK: - Ratings Pre-Prompt Alerts
extension RatingsHandler
{
    internal func ratingsPrePromptAlert(_ yesActionBlock:((_ action: UIAlertAction) -> Void)? = nil,
                                        noActionBlock:((_ action: UIAlertAction) -> Void)? = nil) -> UIAlertController
    {
        let message = NSLocalizedString("Do you like our App?", comment: "Do you like our App?")
        let alertController = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler:
            {(action) in
            iRate.sharedInstance().promptIfNetworkAvailable()
            
            if let yesBlock = yesActionBlock
            { yesBlock(action) }
            })
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .cancel, handler: {(action) in
            if let noBlock = noActionBlock
            { noBlock(action) }
        })
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        return alertController
    }
    
    internal func helpUsImproveAlert(_ yesActionBlock:((_ action: UIAlertAction) -> Void)? = nil,
                                     noActionBlock:((_ action: UIAlertAction) -> Void)? = nil) -> UIAlertController
    {
        let message = NSLocalizedString("Would you like to help us improve?", comment: "Would you like to help us improve?")
        let yesTitle = NSLocalizedString("Sure", comment: "Sure")
        let alertController = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: yesTitle, style: .default, handler:
            { (action) in
                if let yesBlock = yesActionBlock
                { yesBlock(action) }
        })
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .cancel, handler: { (action) in
            if let noBlock = noActionBlock
            { noBlock(action) }
        })
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        return alertController
    }
    
    internal func populateSupportEmail() -> MFMailComposeViewController?
    {
        var mailController: MFMailComposeViewController? = nil
        
        if MFMailComposeViewController.canSendMail()
        {
            mailController = MFMailComposeViewController.init()
            let uID = Platform.sharedInstance.currentUser.ID.nonUniqueIdentifier
            
            let mailSubject = NSLocalizedString("Improve Parents App - iOS", comment: "Improve Parents App - iOS")
            let recipientEmail = NSLocalizedString("support@edmodo.com", comment: "support@edmodo.com")
            let messageBody = NSLocalizedString("Hello Edmodo Staff,\n Here are a few things I think will make the Parents App better:\n", comment: "Help us improve email body")
            
            if let controller = mailController
            {
                controller.setToRecipients([recipientEmail])
                controller.setSubject("\(mailSubject) (uid:\(uID))")
                controller.setMessageBody(messageBody, isHTML: false)
            }
        }
        
        return mailController
    }
}

extension RatingsHandler : iRateDelegate
{
    public func iRateDidPromptForRating()
    {
        EDMixpanel.sharedInstance.trackEvent(withEventName: "rate-app_view", params:[String : AnyObject]())
    }
    
    public func iRateUserDidAttemptToRateApp()
    {
        EDMixpanel.sharedInstance.trackEvent(withEventName: "rate-app_rate-click", params:[String : AnyObject]())
    }
    
    public func iRateUserDidDeclineToRateApp()
    {
        EDMixpanel.sharedInstance.trackEvent(withEventName: "rate-app_no-click", params:[String : AnyObject]())
    }
    
    public func iRateUserDidRequestReminderToRateApp()
    {
        EDMixpanel.sharedInstance.trackEvent(withEventName: "rate-app_remind-click", params:[String : AnyObject]())
    }
}
