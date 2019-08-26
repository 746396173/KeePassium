//  KeePassium Password Manager
//  Copyright © 2018–2019 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

fileprivate let gregoreanCalendar = Calendar(identifier: .gregorian)

fileprivate let validFrom = DateComponents(
    calendar: gregoreanCalendar,
    timeZone: TimeZone.autoupdatingCurrent,
    year: 2019, month: 8, day: 21,
    hour: 0, minute: 0, second: 0).date!
fileprivate let validUntil = DateComponents(
    calendar: gregoreanCalendar,
    timeZone: TimeZone.autoupdatingCurrent,
    year: 2019, month: 8, day: 31,
    hour: 23, minute: 59, second: 59).date!
fileprivate let formattedDateUntil = DateFormatter
    .localizedString(from: validUntil, dateStyle: .medium, timeStyle: .none)

class _201908_SpecialPricesExpireNews: NewsItem {
    let key = "201908_SpecialPricesExpire"
    
    var isCurrent: Bool {
        let now = Date()
        let isPastStart = gregoreanCalendar
            .compare(validFrom, to: now, toGranularity: .minute) == .orderedAscending
        let isBeforeEnd = gregoreanCalendar
            .compare(validUntil, to: now, toGranularity: .minute) == .orderedDescending
        return isPastStart && isBeforeEnd
    }
    
    lazy var title = "Early bird promo ends \(formattedDateUntil)" // do not localize
    
    func show(in viewController: UIViewController) {
        #if AUTOFILL_EXT
        let alert = UIAlertController.make(
            title: self.title,
            message: "Please open the main app from your home screen for further details.",
            cancelButtonTitle: LString.actionDismiss)
        viewController.present(alert, animated: true, completion: nil)
        // keep the news visible until opened in the main app
        #elseif MAIN_APP
        let premiumCoordinator = PremiumCoordinator(presentingViewController: viewController)
        premiumCoordinator.delegate = self
        premiumCoordinator.start()
        isHidden = true // don't show these news again
        #endif
    }
    
}

#if MAIN_APP
extension _201908_SpecialPricesExpireNews: PremiumCoordinatorDelegate {
    func didFinish(_ premiumCoordinator: PremiumCoordinator) {
        // nothing to do
    }
}
#endif
