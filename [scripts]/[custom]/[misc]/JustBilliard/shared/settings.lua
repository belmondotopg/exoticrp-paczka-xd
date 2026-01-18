-- Debug mode
DEBUG_ENABLED = false

-- Cue prop hash. Make sure 3D model has same dimensions as default `js_prop_pool_cue`.
PROP_CUE_HASH = `js_prop_pool_cue`

-- Hit power of cue
DEFAULT_CUE_HIT_POWER = 1.0

-- Progressbar / Manual force adjustment
PROGRESSBAR_FOR_CUE_HIT_ENABLED = true

-- First person camera
FIRST_PERSON_CAMERA_ENABLED_DURING_AIMING = true

-- STREAMING (render distance of tables)
STREAMING_DISTANCE = 30.0

-- See PoolSimulation.js for relative values
TABLE_ANGLE_OFFSET = -90.0
TABLE_LENGTH = 2.7
TABLE_WIDTH = 1.54
TABLE_BALL_RADIUS = 0.04
TABLE_SCALE = 3.0
TABLE_PLAYER_POS_OFFSET = 0.35
TABLE_BALL_PLACEMENT_CAMERA_HEIGHT = 2.0
TABLE_BALL_PLACEMENT_CAMERA_FOV = 50.0
TABLE_BALL_PLACEMENT_MOVEMENT_SPEED = 0.015
TABLE_BALL_PLACEMENT_BALL_ALPHA = 220
TABLE_BALL_PLACEMENT_BALL_OUTLINE_COLOR = {r = 141, g = 64, b = 114, a = 255}

-- Interpolation and simulation settings
-- Optimal values: server 1/45 client 1/240 velocity 0.25
INTERPOLATION_SERVER_DELTA_TIME = 1/45
INTERPOLATION_CLIENT_DELTA_TIME = 1/240
SIMULATION_STOP_AT_BALL_MAX_VELOCITY = 0.25