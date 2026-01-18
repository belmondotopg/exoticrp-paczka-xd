// Import planck.js as ES module
const { World, Vec2, CircleShape, FixtureType, Testbed, Polygon, Circle } = planck;
const PlankMath = planck.Math;

let idIncrement =  0;
class PoolSimulation {
    constructor(config = {}) {
        this.id = 'id-' + idIncrement;
        idIncrement++;

        // See config.lua for relative values
        this.scale = 3.0;
        this.width = 2.70 * this.scale;
        this.height = 1.54 * this.scale;
        this.ballRadius = 0.04 * this.scale;
        this.pocketRadius = 0.10 * this.scale;
        
        this.debugEnabled = config.debugEnabled || false;

        this.precision = 6;
        
        this.railConfig = {
            friction: 0.1,
            restitution: 0.9,
            userData: 'rail'
        };
        
        this.ballConfig = {
            friction: 0.1,
            restitution: 0.99,
            density: 1,
            userData: 'ball'
        };
        
        this.ballBodyConfig = {
            linearDamping: 1.5,
            angularDamping: 1,
            allowSleep: false,
            bullet: true,
        };

        this.colors = [
            { fill: '#ffdd00', stroke: '#000000', id: 1 },
            { fill: '#ffdd00', stroke: '#ffffff', id: 2 },
            { fill: '#ff3300', stroke: '#000000', id: 3 },
            { fill: '#ff3300', stroke: '#ffffff', id: 4 },
            { fill: '#662200', stroke: '#000000', id: 5 },
            { fill: '#662200', stroke: '#ffffff', id: 6 },
            { fill: '#ff8800', stroke: '#000000', id: 7 },
            { fill: '#ff8800', stroke: '#ffffff', id: 8 },
            { fill: '#00bb11', stroke: '#000000', id: 9 },
            { fill: '#00bb11', stroke: '#ffffff', id: 10 },
            { fill: '#9900ff', stroke: '#000000', id: 11 },
            { fill: '#9900ff', stroke: '#ffffff', id: 12 },
            { fill: '#0077ff', stroke: '#000000', id: 13 },
            { fill: '#0077ff', stroke: '#ffffff', id: 14 }
        ];

        this.world = null;
        this.balls = [];
        this.simulationTime = 0;
        this.ballBounced = false;
        this.initialize();

        this.collisionSystem = new BallCollisionSound();
    }

    round(value) {
        return Number(value.toFixed(this.precision));
    }

    serializeVec2(vec) {
        return {
            x: this.round(vec.x),
            y: this.round(vec.y)
        };
    }

    deserializeVec2(obj) {
        return Vec2(this.round(obj.x), this.round(obj.y));
    }

    initialize() {
        this.world = World({
            gravity: Vec2(0, 0),
            velocityThreshold: 0,
        });

        if (this.debugEnabled) {
            this.testbed = Testbed.mount();
            this.testbed.x = 0;
            this.testbed.y = 0;
            this.testbed.width = this.width * 1.2;
            this.testbed.height = this.height * 1.2;
            this.testbed.ratio = 100;
            this.testbed.mouseForce = -30;
            this.testbed.start(this.world);
        }
        
        this.setupTable();
        
        if (this.balls.length === 0) {
            this.setupBalls();
        }
        
        this.setupCollisionHandling();
    }

    setupTable() {
        const { width, height, pocketRadius } = this;
        const SPI4 = PlankMath.sin(PlankMath.PI / 4);

        const railH = [
            Vec2(pocketRadius, height * 0.5),
            Vec2(pocketRadius, height * 0.5 + pocketRadius),
            Vec2(width * 0.5 - pocketRadius / SPI4 + pocketRadius, height * 0.5 + pocketRadius),
            Vec2(width * 0.5 - pocketRadius / SPI4, height * 0.5)
        ];

        const railV = [
            Vec2(width * 0.5, -(height * 0.5 - pocketRadius / SPI4)),
            Vec2(width * 0.5 + pocketRadius, -(height * 0.5 - pocketRadius / SPI4 + pocketRadius)),
            Vec2(width * 0.5 + pocketRadius, height * 0.5 - pocketRadius / SPI4 + pocketRadius),
            Vec2(width * 0.5, height * 0.5 - pocketRadius / SPI4)
        ];

        this.createRails(railH, railV);
        this.createPockets();
    }

    createRails(railH, railV) {
        // Create horizontal and vertical rails
        let r1 = this.world.createBody().createFixture(Polygon(railV.map(Vec2.scaleFn(+1, +1))), this.railConfig);
        let r2 = this.world.createBody().createFixture(Polygon(railV.map(Vec2.scaleFn(-1, +1))), this.railConfig);
        let r3 = this.world.createBody().createFixture(Polygon(railH.map(Vec2.scaleFn(+1, +1))), this.railConfig);
        let r4 = this.world.createBody().createFixture(Polygon(railH.map(Vec2.scaleFn(-1, +1))), this.railConfig);
        let r5 = this.world.createBody().createFixture(Polygon(railH.map(Vec2.scaleFn(+1, -1))), this.railConfig);
        let r6 = this.world.createBody().createFixture(Polygon(railH.map(Vec2.scaleFn(-1, -1))), this.railConfig);
    
        r1.isCushion = true;
        r2.isCushion = true;
        r3.isCushion = true;
        r4.isCushion = true;
        r5.isCushion = true;
        r6.isCushion = true;
    }

    createPockets() {
        const { width, height, pocketRadius } = this;
        const pocketPositions = [
            [0, -height * .5 - pocketRadius * 1.5],
            [0, +height * .5 + pocketRadius * 1.5],
            [+width * .5 + pocketRadius * .7, +height * .5 + pocketRadius * .7],
            [-width * .5 - pocketRadius * .7, +height * .5 + pocketRadius * .7],
            [+width * .5 + pocketRadius * .7, -height * .5 - pocketRadius * .7],
            [-width * .5 - pocketRadius * .7, -height * .5 - pocketRadius * .7]
        ];

        pocketPositions.forEach(([x, y]) => {
            this.world.createBody().createFixture(
                Circle(Vec2(x, y), pocketRadius),
                { userData: 'pocket' }
            );
        });
    }

    createRack() {
        const r = this.ballRadius;
        const n = 5;
        const d = r * 2;
        const l = PlankMath.sin(PlankMath.PI / 3) * d;
        const balls = [];

        for (let i = 0; i < n; i++) {
            for (let j = 0; j <= i; j++) {
                balls.push({
                    x: this.round(i * l),
                    y: this.round((j - i * 0.5) * d),
                    vx: 0,
                    vy: 0,
                });
            }
        }
        return balls;
    }

    setupBalls() {
        // Create rack of balls
        const rackBalls = this.createRack().map(ball => ({
            ...ball,
            x: ball.x + this.width / 4,
            y: ball.y
        }));
        
        // Add cue ball
        rackBalls.push({ 
            x: -this.width / 4, 
            y: 0,
            vx: 0,
            vy: 0
        });

        // Assign colors
        this.assignBallColors(rackBalls);

        // Create physics bodies for balls
        this.createBallBodies(rackBalls);
    }

    createBallBodies(ballsData) {
        this.balls = ballsData.map(ballData => {
            const ball = this.world.createDynamicBody({
                ...this.ballBodyConfig,
                position: Vec2(this.round(ballData.x), this.round(ballData.y))
            });
            
            // if (ballData.vx !== undefined && ballData.vy !== undefined) {
            //     ball.setLinearVelocity(Vec2(
            //         this.round(ballData.vx),
            //         this.round(ballData.vy)
            //     ));
            // }
            
            ball.setBullet(true);

            ball.createFixture(Circle(this.ballRadius), this.ballConfig);
            ball.render = ballData.render;
            ball.id = ballData.render.id;
            ball.isBall = true;
            return ball;
        });
    }

    assignBallColors(balls) {
        const shuffledColors = [...this.colors].sort(() => Math.random() - 0.5);
        balls.forEach((ball, i) => {
            if (i < shuffledColors.length) {
                ball.render = shuffledColors[i];
                ball.id = ball.render.id;
            }
        });
        
        // Set black and white balls (last 2 balls from rack function)
        balls[balls.length - 2].render = {
            fill: 'black',
            stroke: 'white',
            id: 15,
        };
        balls[balls.length - 1].render = {
            fill: 'white',
            stroke: 'white',
            id: 16,
        };
    }

    setupCollisionHandling() {
        this.world.on('begin-contact', (contact) => {
            const bodyA = contact.getFixtureA().getBody();
            const bodyB = contact.getFixtureB().getBody();
            
            // Get the relative velocity at the point of contact
            const worldManifold = contact.getWorldManifold();
            const velocity = worldManifold.tangentSpeed;
        
            // Check if both bodies are balls
            if (bodyA.isBall && bodyB.isBall) {
                let [inCollision, volume] = this.collisionSystem.isBallCollision(bodyA, bodyB);
                if (inCollision) {
                    this.ballBounced = inCollision;
                    // this.ballBouncedInfo = `${bodyA.id}<->${bodyB.id}`;
                    this.ballBouncedInfo = volume;
                }
            }
            // Check if one body is a cushion
            else if (bodyA.isBall && bodyB.isCushion) {
                // this.collisionSystem.isBallCollision(bodyA.userData, velocity);
            }
            else if (bodyA.isCushion && bodyB.isBall) {
                // this.collisionSystem.isBallCollision(bodyB.userData, velocity);
            }
        });
        this.world.on('post-solve', (contact) => {
            const fA = contact.getFixtureA();
            const fB = contact.getFixtureB();
            if (fA === null || fB === null) {
                return;
            }

            const bA = fA.getBody();
            const bB = fB.getBody();

            const pocket = fA.getUserData() === 'pocket' && bA || fB.getUserData() === 'pocket' && bB;
            const ball = fA.getUserData() === 'ball' && bA || fB.getUserData() === 'ball' && bB;
            
            if (ball && pocket) {
                // Check if ball is already scheduled for destruction
                if (ball.isScheduledForDestruction) return;
                
                // Mark the ball
                ball.isScheduledForDestruction = true;
                
                // Use a flag on the body to ignore collisions
                ball.setLinearVelocity(Vec2(0.0, 0.0))
                ball.setActive(false);
                
                // // Remove from array
                // this.balls = this.balls.filter(b => b !== ball);
                // setTimeout(() => {
                //     this.world.destroyBody(ball);
                // }, 1);
            }
        });
    }

    step(deltaTime) {
        this.world.step(deltaTime);
        this.simulationTime = this.simulationTime + deltaTime;
        return this.getBallPositions();
    }

    getBallPositions() {
        return this.balls.map(ball => {
            const pos = this.serializeVec2(ball.getPosition());
            const vel = this.serializeVec2(ball.getLinearVelocity());
            return {
                id: ball.id,
                x: pos.x,
                y: pos.y,
                vx: vel.x,
                vy: vel.y,
                render: ball.render,
                active: ball.isActive(),
            };
        });
    }

    getState() {
        let ballBounced = this.ballBounced;
        this.ballBounced = false;

        let ballBouncedInfo = this.ballBouncedInfo;
        this.ballBouncedInfo = false;

        return {
            balls: this.getBallPositions(),
            simulationTime: this.simulationTime,
            ballBounced: ballBounced,
            ballBouncedInfo: ballBouncedInfo,
        };
    }

    setState(state) {
        if (state.simulationTime !== undefined) {
            this.simulationTime = this.round(state.simulationTime);
        }

        this.balls.forEach(ball => this.world.destroyBody(ball));
        this.balls = [];

        this.createBallBodies(state.balls.map(ball => ({
            ...ball,
            x: this.round(ball.x),
            y: this.round(ball.y),
            vx: this.round(ball.vx),
            vy: this.round(ball.vy)
        })));
    }

    reset() {
        // Clear existing balls
        this.balls.forEach(ball => this.world.destroyBody(ball));
        this.balls = [];
        // Recreate balls
        this.setupBalls();
    }

    strikeBall(direction, power) {
        if (this.balls.length > 0) {
            const cueBall = this.balls.find((b) => this.isCueBall(b));
            // const cueBall = this.balls[this.balls.length - 1];

            const normalizedDirection = Vec2(
                this.round(direction.x),
                this.round(direction.y)
            );
            const normalizedPower = this.round(power);
            
            cueBall.applyLinearImpulse(
                Vec2(
                    this.round(normalizedDirection.x * normalizedPower),
                    this.round(normalizedDirection.y * normalizedPower)
                ),
                cueBall.getPosition()
            );
        }
    }

    verifyState(otherState) {
        const currentState = this.getState();
        
        if (this.round(currentState.simulationTime) !== this.round(otherState.simulationTime)) {
            return {
                matches: false,
                reason: 'simulation_time_mismatch',
                expected: currentState.simulationTime,
                actual: otherState.simulationTime
            };
        }

        if (currentState.balls.length !== otherState.balls.length) {
            return {
                matches: false,
                reason: 'ball_count_mismatch',
                expected: currentState.balls.length,
                actual: otherState.balls.length
            };
        }

        for (let i = 0; i < currentState.balls.length; i++) {
            const currentBall = currentState.balls[i];
            const otherBall = otherState.balls.find(b => b.id === currentBall.id);
            
            if (!otherBall) {
                return {
                    matches: false,
                    reason: 'ball_missing',
                    ballId: currentBall.id
                };
            }

            if (
                this.round(currentBall.x) !== this.round(otherBall.x) ||
                this.round(currentBall.y) !== this.round(otherBall.y) ||
                this.round(currentBall.vx) !== this.round(otherBall.vx) ||
                this.round(currentBall.vy) !== this.round(otherBall.vy)
            ) {
                return {
                    matches: false,
                    reason: 'ball_state_mismatch',
                    ballId: currentBall.id,
                    expected: currentBall,
                    actual: otherBall
                };
            }
        }

        return { matches: true };
    }

    isCueBall(ball) {
        return ball.id === 16;
    }

    resetWhiteBall(coords) {
        const cueBall = this.balls.find((b) => this.isCueBall(b));
        cueBall.setPosition(Vec2(coords.x, coords.y));
        cueBall.setActive(true);
        cueBall.isScheduledForDestruction = false;
    }

    resetTable() {
        this.balls.forEach(ball => this.world.destroyBody(ball));
        this.balls = [];
        this.setupBalls();
    }
}

class BallCollisionSound {
    constructor() {
        // Initialize collision state tracking
        this.lastCollisionTime = {};  // Track last collision time for each ball pair
        this.collisionCooldown = 50;  // Milliseconds to wait before playing same collision again
    }

    // Generate unique ID for ball pair
    getBallPairId(ball1, ball2) {
        // Sort IDs to ensure consistent pair identification regardless of order
        const ids = [ball1.id, ball2.id].sort();
        return `${ids[0]}-${ids[1]}`;
    }

    // Check if enough time has passed since last collision
    canPlaySound(pairId) {
        const now = Date.now();
        if (!this.lastCollisionTime[pairId]) return true;
        return (now - this.lastCollisionTime[pairId]) > this.collisionCooldown;
    }

    getCollisionSpeed(bodyA, bodyB) {
        const velA = bodyA.getLinearVelocity();
        const velB = bodyB.getLinearVelocity();
        
        // Calculate relative velocity
        const relativeVelX = velA.x - velB.x;
        const relativeVelY = velA.y - velB.y;
        
        // Return the magnitude of relative velocity
        return Math.sqrt(relativeVelX * relativeVelX + relativeVelY * relativeVelY);
    }

    // Handle ball-to-ball collision
    isBallCollision(ball1, ball2) {
        const pairId = this.getBallPairId(ball1, ball2);

        // Calculate collision speed
        const speed = this.getCollisionSpeed(ball1, ball2);

        if (this.canPlaySound(pairId)) {

            
            // Adjust volume based on collision speed
            // You might need to adjust this scaling factor based on your game's physics scale
            const impactVelocity = Math.min(speed / 10, 1);

            // // Play sound with slight random pitch variation for realism
            // const sound = this.collisionSound.cloneNode();
            // sound.playbackRate = 0.9 + (Math.random() * 0.2); // Random pitch between 0.9 and 1.1
            // sound.play();

            // Update last collision time
            this.lastCollisionTime[pairId] = Date.now();
            return [true, impactVelocity];
        }
        return [false, 0];
    }

    // Handle ball-to-cushion collision
    onCushionCollision(ball, velocity) {
        const pairId = `cushion-${ball.id}`;
        
        if (this.canPlaySound(pairId)) {
            // Adjust volume based on collision velocity
            const impactVelocity = Math.min(Math.abs(velocity) / 15, 1);
            this.cushionSound.volume = impactVelocity;
            
            // Play sound with slight random pitch variation
            const sound = this.cushionSound.cloneNode();
            sound.playbackRate = 0.95 + (Math.random() * 0.1);
            sound.play();
            
            this.lastCollisionTime[pairId] = Date.now();
        }
    }
}


let debugInBrowser = false;
if (debugInBrowser) {
    const poolGame = new PoolSimulation({
        width: 2.70,
        height: 1.54,
        debugEnabled: true
    });
} else {
    let simulations = {};

    exports('initSimulation', function (state) {
        const simulation = new PoolSimulation();
        if (state) {
            simulation.setState(state);
        }
        let id = simulation.id;
        simulations[id] = simulation;
        return id;
    });

    exports('getSimulationState', function (id) {
        return simulations[id].getState();
    });

    exports('step', function (id, dt) {
        const simulation = simulations[id];
        return simulation.step(dt);
    });

    exports('strikeBall', function (id, direction, power) {
        const simulation = simulations[id];
        simulation.strikeBall(direction, power);
        return simulation.getState();
    });

    exports('setSimulationState', function (id, state) {
        simulations[id].setState(state);
    });

    exports('resetWhiteBall', function (id, coords) {
        simulations[id].resetWhiteBall(coords);
    });

    exports('resetTable', function (id) {
        simulations[id].resetTable();
    });
}