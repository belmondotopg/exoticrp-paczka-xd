import { useNotifications } from "@/modules/notifications/api/use-notifications";
import { NotificationCard } from "@/modules/notifications/ui/components/notification-card";
import { useSettings } from "@/modules/settings/hooks/use-settings";

export const NotificationsView = () => {
    const { notifications } = useNotifications();
    const { settings } = useSettings();

    if (!settings["show-general-notifications"]) return null;

    return (
        <div className="w-[310px] flex flex-col gap-y-3 fixed top-36 right-10">
            {notifications.map((notification) => (
                <NotificationCard 
                    key={notification.id || `notification-${notification.html}-${Date.now()}`}
                    {...notification} 
                />
            ))}
        </div>
    )
}
