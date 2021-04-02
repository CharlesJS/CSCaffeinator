//
//  CSCaffeinator.swift
//  CSCaffeinator
//
//  Created by Charles Srstka on 4/1/21.
//

import Foundation
import IOKit
import IOKit.pwr_mgt
import CSErrors

public class CSCaffeinator {
    public enum AssertionType {
        /// Prevents the system from sleeping automatically due to a lack of user activity.
        ///
        /// Will prevent the system from sleeping due to a period of idle user activity.
        /// The display may dim and idle sleep, but the system may not idle sleep. The system may still sleep for lid close,
        /// Apple menu, low battery, or other sleep reasons.
        ///
        /// This assertion has no effect if the system is in Dark Wake.
        case preventSystemSleep
        
        /// Prevents the display from dimming automatically.
        ///
        /// Will prevent the display from turning off due to a period of idle user activity.
        /// Note that the display may still sleep for other reasons, like a user closing a
        /// portable's lid or the machine sleeping. If the display is already off, this
        /// assertion does not light up the display. If display needs to be turned on, then
        /// consider calling function <code>@link IOPMAssertionDeclareUserActivity@/link</code>.
        /// While the display is prevented from dimming, the system cannot go into idle sleep.
        ///
        /// This assertion has no effect if the system is in Dark Wake.
        case preventDisplaySleep
        
        /// Prevent attached disks from idling into lower power states.
        ///
        /// Will prevent attached disks and optical media from idling into lower power states.
        /// Apps who rely on real-time access to disks should create this assertion to avoid
        /// latencies caused by disks changing power states. For example, audio and video performance
        /// or recording apps may benefit from this assertion. Most Apps should not take this assertion;
        /// preventing disk idle consumes battery life, and most apps don't require the low latency
        /// disk access that this provides.
        /// This assertion doesn't increase a disk's power state (it just prevents that device from idling).
        /// After creating this assertion, the caller should perform disk I/O on the necessary drives to
        /// ensure that they're in a usable power state.
        /// The system may still sleep while this assertion is active.
        /// Callers should also use `.preventUserIdleSystemSleep`,
        /// if necessary, to prevent idle system sleep.
        case preventDiskIdle
        
        fileprivate var rawValue: String {
            switch self {
            case .preventSystemSleep:
                return kIOPMAssertPreventUserIdleSystemSleep
            case .preventDisplaySleep:
                return kIOPMAssertPreventUserIdleDisplaySleep
            case .preventDiskIdle:
                return kIOPMAssertPreventDiskIdle
            }
        }
    }
    
    private let id: IOPMAssertionID
    private var stopped = false
    
    public init(type: AssertionType, reason: String) throws {
        if reason.utf16.count > 128 {
            throw POSIXError(.EINVAL)
        }
        
        var id: IOPMAssertionID = 0
        
        let err = IOPMAssertionCreateWithName(
            type.rawValue as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            type.rawValue as CFString,
            &id
        )
        
        if err != kIOReturnSuccess {
            throw ioKitError(err)
        }
        
        self.id = id
    }
    
    deinit {
        if !self.stopped {
            _ = try? self.stop()
        }
    }
    
    public func stop() throws {
        if !self.stopped {
            let err = IOPMAssertionRelease(self.id)
            
            if err == kIOReturnSuccess {
                self.stopped = true
            } else {
                throw ioKitError(err)
            }
        }
    }
}
