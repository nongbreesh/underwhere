protocol ModalTransitionListener {
    func popoverDismissed()
}

class ModalTransitionMediator {
    /* Singleton */
    class var instance: ModalTransitionMediator {
        struct Static {
            static let instance: ModalTransitionMediator = ModalTransitionMediator()
        }
        return Static.instance
    }

    private var listener: ModalTransitionListener?

    private init() {

    }

    func setListener(listener: ModalTransitionListener) {
        self.listener = listener
    }

    func sendPopoverDismissed(modelChanged: Bool) {
        listener?.popoverDismissed()
    }
}


protocol Modal_Profile_TransitionListener {
    func popoverDismissed()
}

class Modal_Profile_TransitionMediator {
    /* Singleton */
    class var instance: Modal_Profile_TransitionMediator {
        struct Static {
            static let instance: Modal_Profile_TransitionMediator = Modal_Profile_TransitionMediator()
        }
        return Static.instance
    }

    private var listener: Modal_Profile_TransitionListener?

    private init() {

    }

    func setListener(listener: Modal_Profile_TransitionListener) {
        self.listener = listener
    }

    func sendPopoverDismissed(modelChanged: Bool) {
        listener?.popoverDismissed()
    }
}




protocol ControllerListener {
    func callbackDelegate()
}

class ControllerTransitionMediator {
    /* Singleton */
    class var instance: ControllerTransitionMediator {
        struct Static {
            static let instance: ControllerTransitionMediator = ControllerTransitionMediator()
        }
        return Static.instance
    }

    private var listener: ControllerListener?

    private init() {

    }

    func setListener(listener: ControllerListener) {
        self.listener = listener
    }

    func sendFromDelegate(modelChanged: Bool) {
        listener?.callbackDelegate()
    }
}



protocol BadgeListener {
    func UpdateBadge()
}

class BadgeTransitionMediator {
    /* Singleton */
    class var instance: BadgeTransitionMediator {
        struct Static {
            static let instance: BadgeTransitionMediator = BadgeTransitionMediator()
        }
        return Static.instance
    }

    private var listener: BadgeListener?

    private init() {

    }

    func setListener(listener: BadgeListener) {
        self.listener = listener
    }

    func sendUpdateBadge(modelChanged: Bool) {
        listener?.UpdateBadge()
    }
}

protocol NotificationListener {
    func UpdateNotificationData()
}

class NotificationTransitionMediator {
    /* Singleton */
    class var instance: NotificationTransitionMediator {
        struct Static {
            static let instance: NotificationTransitionMediator = NotificationTransitionMediator()
        }
        return Static.instance
    }

    private var listener: NotificationListener?

    private init() {

    }

    func setListener(listener: NotificationListener) {
        self.listener = listener
    }

    func sendUpdateNotificationData(modelChanged: Bool) {
        listener?.UpdateNotificationData()
    }
}