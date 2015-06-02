//
//  RatingsHandler.swift
//  Parents
//
//  Created by Yousra Kamoona on 6/1/15.
//  Copyright (c) 2015 Edmodo. All rights reserved.
//

import Foundation

public class RatingsHandler : NSObject
{
    static let sharedInstance = RatingsHandler()

    private override init()
    {
        super.init()
        
        self.configureiRate()
        
    }
    
    private func configureiRate()
    {
        //configure iRate
        iRate.sharedInstance().eventsUntilPrompt = 2
        iRate.sharedInstance().daysUntilPrompt = 0
        iRate.sharedInstance().usesUntilPrompt = 2
        iRate.sharedInstance().remindPeriod = 7
        iRate.sharedInstance().promptAtLaunch = false
        
        iRate.sharedInstance().delegate = self
        
        //overriding the default iRate strings
        iRate.sharedInstance().messageTitle = NSLocalizedString("Rate MyApp", comment: "iRate message title")
        iRate.sharedInstance().message = NSLocalizedString("Ask Tarunya", comment: "iRate message")
        iRate.sharedInstance().cancelButtonLabel = NSLocalizedString("No, Thanks", comment: "iRate decline button")
        iRate.sharedInstance().remindButtonLabel = NSLocalizedString("Remind Me Later", comment: "iRate remind button")
        iRate.sharedInstance().rateButtonLabel = NSLocalizedString("Rate It Now", comment: "iRate accept button")
    }
    
    internal func logEvent()
    {
        //increment events count and prompt rating alert if all criteria are met
        //cretieria: 2 replies or detail view taps or a combination of the 2.
        iRate.sharedInstance().logEvent(false)
    }
    
    private func checkUser()
    {
        
    }
    
    private func resetUserDefaults()
    {
        
    }
}

extension RatingsHandler : iRateDelegate
{
    public func iRateDidPromptForRating()
    {
        
    }
    
    public func iRateUserDidAttemptToRateApp()
    {
        
    }
    
    public func iRateUserDidDeclineToRateApp()
    {
        
    }
    
    public func iRateUserDidRequestReminderToRateApp()
    {
        
    }
}
