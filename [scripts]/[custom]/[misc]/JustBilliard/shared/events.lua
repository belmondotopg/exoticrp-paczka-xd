-- Resource name
RESOURCE_NAME = GetCurrentResourceName()

-- Statebags
STATEBAG_CUE_IN_HAND = 'js-pool:hasCueProp'

-- Events
EVENTS = {
    ['resetWhiteBall'] = 'js-pool:resetWhiteBall',
    ['ballPlacementCancelled'] = 'js-pool:ballPlacementCancelled',
    ['toggleCueInHand'] = 'js-pool:toggleCueInHand',
    ['cueStatus'] = 'js-pool:cueStatus',
    ['strikeBall'] = 'js-pool:strikeBall',
    ['onCueStandObservingStarted'] = 'js-pool:onCueStandObservingStarted',
    ['onCueStandObservingStopped'] = 'js-pool:onCueStandObservingStopped',
    ['locations_range'] = 'js-pool:locations_range',
    ['showSuccessNotification'] = 'js-pool:showSuccessNotification',
    ['showWarningNotification'] = 'js-pool:showWarningNotification',
    ['showErrorNotification'] = 'js-pool:showErrorNotification',
    ['inRange2_Interaction'] = 'js-pool:inRange2_Interaction',
    ['joinTable'] = 'js-pool:joinTable',
    ['resetTable'] = 'js-pool:resetTable',
    ['joinedTable'] = 'js-pool:joinedTable',
    ['failedJoinToTable'] = 'js-pool:failedJoinToTable',
    ['in_range'] = 'js-pool:in_range',
    ['out_range'] = 'js-pool:out_range',
    ['observe_game'] = 'js-pool:observe_game',
    ['stop_observe_game'] = 'js-pool:stop_observe_game',
    ['setSimulationState'] = 'js-pool:setSimulationState',
    ['quitTable'] = 'js-pool:quitTable',
    ['onGameObservingStarted'] = 'js-pool:onGameObservingStarted',
    ['onGameObservingStopped'] = 'js-pool:onGameObservingStopped',
    ['markMyTurn'] = 'js-pool:markMyTurn',
    ['unmarkMyTurn'] = 'js-pool:unmarkMyTurn',
    ['turnUpdated'] = 'js-pool:turnUpdated',
    ['inRangeOfCueExistance'] = 'js-pool:inRangeOfCueExistance',
}