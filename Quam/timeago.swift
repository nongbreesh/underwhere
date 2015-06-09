func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.currentCalendar()


    let unitFlags = NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitWeekOfYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitSecond
    let now = NSDate()
    let earliest = now.earlierDate(date)
    let latest = (earliest == now) ? date : now

    let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options: nil)



    var year =  components.year
    var month =  components.month
    var day =  components.day
    var week =  components.weekOfYear
    var hour =  components.hour



    switch calendar.calendarIdentifier{
    case "buddhist":
        year -= 543
        break
    case "japanese":
        year -= 1987
        month -= 11
        day -= 12
        week -= 4
        hour -= 21
        break
    default :
        break
    }

    if (year >= 2) {
        return "\(year) y ago"
    } else if (year >= 1){
        if (numericDates){
            return "1 y"
        } else {
            return "Last year"
        }
    } else if (month >= 2) {
        return "\(month) m"
    } else if (month >= 1){
        if (numericDates){
            return "1 m"
        } else {
            return "Last month"
        }
    } else if (week >= 2) {
        return "\(week) w"
    } else if (week >= 1){
        if (numericDates){
            return "1 w"
        } else {
            return "Last week"
        }
    } else if (day >= 2) {
        return "\(day) days"
    } else if (day >= 1){
        if (numericDates){
            return "1 day"
        } else {
            return "Yesterday"
        }
    } else if (components.hour >= 2) {
        return "\(components.hour) hrs"
    } else if (components.hour >= 1){
        if (numericDates){
            return "1 hr"
        } else {
            return "An hour ago"
        }
    } else if (components.minute >= 2) {
        return "\(components.minute) mins"
    } else if (components.minute >= 1){
        if (numericDates){
            return "1 min "
        } else {
            return "A min ago"
        }
    } else if (components.second >= 3) {
        return "\(components.second) seconds ago"
    } else {
        return "Just now"
    }
    
}