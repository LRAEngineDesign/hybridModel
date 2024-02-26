
% Constants
g0 = 9.81;              % m/s^2

% Rocket Parameters
wetMass = 30;           % kg
propMass = 13.6077711;  % kg, eventually Monte-Carlo
TTW = 6;                % thrust-to-weight ratio    
targetISP = 250;        % seconds

CSA = 0.061311605;      % m, from 5.5 inches
cd = 0.5;               % drag coefficient, eventually have to lookup cd from mach and base drag

% Engine Calculations
avgThrust_est = wetMass*g0*TTW;                 % Average Thrust estimate, N
burnTime = propMass*targetISP*g0/avgThrust_est; % seconds
disp(burnTime)

%% Flight Model
alt = 0;    % initial altitude
v = 0;      % initial velocity  

% Vectors for Plotting
alt_flight = [alt];
v_flight = [v];
drag_flight = [0];
weight_flight = [0];

dt = 0.01; t = 0;

rhoAir = 1.225; % kg/m^3, eventually have lookup tables for atmo data and move into loop

while (alt >= 0)

    % Forces
    weight = wetMass * g0;
    drag = .5*rhoAir*v^2*cd*CSA;

    if (v >= 0) % ascent
        if (t <= burnTime) % powered ascent
            a = (avgThrust_est - weight - drag)/wetMass;
        else % coasting
            a = -(weight + drag)/wetMass;
        end
    else % descent w/out parachute
        a = (-weight + drag)/wetMass;
    end

    % Kinematic Equations
    v = v + a*dt;
    alt = alt + v*dt + 0.5*a*dt^2;
    
    % Plotting Vectors
    alt_flight = [alt_flight, alt];
    v_flight = [v_flight, v];
    drag_flight = [drag_flight drag];
    weight_flight = [weight_flight weight];

    t = t + dt;
end

t_flight = 0:dt:t;    % generating time of flight

subplot(211)
grid on
hold on
plot(t_flight, alt_flight)
plot(t_flight, v_flight)
hold off
title('Altitude vs Time')
legend('Altitude', 'Velocity')
xlabel('Time (seconds)')
ylabel('Altitude (meters)')

subplot(212)
grid on
hold on
plot(t_flight, drag_flight)
plot(t_flight, weight_flight)
hold off
title('Forces vs Time')
legend('Drag', 'Weight')
xlabel('Time (seconds)')
ylabel('Forces (N)')

