import { lazy, Suspense } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useVisible } from "@yankes/fivem-react/hooks";

import { Toaster } from "@/components/ui/sonner";
import { useSettings } from "@/modules/settings/hooks/use-settings";

import { HudView } from "@/modules/hud/ui/views/hud-view";
import { ChatView } from "@/modules/chat/ui/views/chat-view";
import { NotificationsView } from "@/modules/notifications/ui/views/notifications-view";
import { TextUIView } from "@/modules/textui/ui/views/textui-view";
import { ProgressBarView } from "@/modules/progress-bar/ui/views/progress-bar-view";
import { WatermarkView } from "@/modules/watermark/ui/views/watermark-view";
import { BodycamView } from "@/modules/bodycam/ui/views/bodycam-view";
import { CarhudView } from "./modules/carhud/ui/views/carhud-view";
import { MulticharacterView } from "./modules/multicharacter/ui/views/multicharacter-view";
import ClotheShopView from "./modules/clotheshop/ui/views/CotheShopView";
import StatisticsView from "./modules/statistics/ui/view/StatisticsView";

const ScoreboardView = lazy(() => import("@/modules/scoreboard/ui/views/scoreboard-view").then(m => ({ default: m.ScoreboardView })));
const PoliceRadarView = lazy(() => import("@/modules/police-radar/ui/views/police-radar-view").then(m => ({ default: m.PoliceRadarView })));
const RadioView = lazy(() => import("@/modules/radio/ui/views/radio-view").then(m => ({ default: m.RadioView })));
const IdentityView = lazy(() => import("@/modules/identity/ui/views/identity-view").then(m => ({ default: m.IdentityView })));
const NPCDialogsView = lazy(() => import("@/modules/npc-dialogs/ui/views/npc-dialogs-view").then(m => ({ default: m.NPCDialogsView })));
const SettingsView = lazy(() => import("@/modules/settings/ui/views/settings-view").then(m => ({ default: m.SettingsView })));
const CrosshairView = lazy(() => import("./modules/crosshair/views/ui/crosshair-view").then(m => ({ default: m.CrosshairView })));
const DocumentIdView = lazy(() => import("./modules/documents/ui/views/document-id-view").then(m => ({ default: m.DocumentIdView })));
const BusinessCardView = lazy(() => import("./modules/documents/ui/views/business-card-view").then(m => ({ default: m.BusinessCardView })));
const BadgeView = lazy(() => import("./modules/documents/ui/views/badge-view").then(m => ({ default: m.BadgeView })));
const JobCenterView = lazy(() => import("./modules/job-center/ui/views/job-center-view").then(m => ({ default: m.JobCenterView })));
const TasksView = lazy(() => import("./modules/tasks/ui/views/tasks-view").then(m => ({ default: m.TasksView })));

// QueryClient poza komponentem - tworzy się tylko raz
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      refetchOnReconnect: false,
      retry: false,
      staleTime: 5 * 60 * 1000, // 5 minut
    },
  },
});

export const App = () => {
  useSettings();
  const { visible } = useVisible("global", true);
  
  return visible && (
    <QueryClientProvider client={queryClient}>
      <Toaster />
      
      {/* Krytyczne i często widoczne komponenty - eager loading */}
      <HudView />
      <ChatView />
      <NotificationsView />
      <TextUIView />
      <ProgressBarView />
      <WatermarkView />
      <BodycamView />
      <CarhudView />
      <MulticharacterView />
      
      {/* Rzadziej używane - lazy loading z fallback */}
      <Suspense fallback={null}>
        <StatisticsView />
        <ScoreboardView />
        <PoliceRadarView />
        <RadioView />
        <IdentityView />
        <NPCDialogsView />
        <SettingsView />
        <ClotheShopView />
        <CrosshairView />
        <DocumentIdView />
        <BusinessCardView />
        <BadgeView />
        <JobCenterView />
        <TasksView />
      </Suspense>
    </QueryClientProvider>
  )
}
