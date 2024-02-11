%% Parameters
% assumes the nitrous is in thermodynamic equilibrium, so using a set
% temperature, can simulate how the properties change over time
% Also, assumes constant flow rate since I don't have an injector model/data yet
% and a predetermined mass of oxidizer in the tank
% Also don't have dimensions for the nitrous tank yet

dt = .01;    % seconds
tmax = 30;  % seconds
volTank = 0.055253077; % m^3
initialTemperature = 293;   % K
totalMass = 40.04;  % kg
oxFlowRate = 2; % kg/s

t = linspace(0, tmax, tmax/dt);

% masses of system: liquid & vapor mass(kg), mass vaporized(kg)
massLiq = zeros(1, length(t)); % kg
massVapor = zeros(1, length(t)); % kg
vaporizedMass = zeros(1, length(t)); % kg

% state of system: ullage(%), temp(K), pressure(kPa)
ullage = zeros(1, length(t)); % percent
temp = zeros(1, length(t)); % K
pressure = zeros(1, length(t)); % kPa

% volLG [liquid & vapor volume(m^3)]
volLiq = zeros(1, length(t));
volVapor = zeros(1, length(t));

%% Initial Conditions
% Using iniTemp, uses thermodynamic properties at that state to calculate
% the starting mass of both liquid and vapor based on 
% Law of Conservation of Mass and Volume

% N2O [liqDensity, vapDensity, vapPressure, hVap, liqSpecHeat, vapSpecHeat]
N2O = NitrousProperties(initialTemperature);

% initial conditions
massLiq(1) = (totalMass-volTank*N2O(2)) / (1-N2O(2)/N2O(1));
vapMass(1) = totalMass - massLiq(1);
ullage(1) = vapMass(1) / (N2O(2)*volTank);
temp(1) = initialTemperature;
pressure(1) = N2O(3);

volLiq(1) = massLiq(1)/N2O(1);
volVapor(1) = massVapor(1)/N2O(2);

%% simulation @ t = 0
% when ox leaves tank, some empty volume is left, so some of the remaining
% liquid vaporizes to restore the equilibrium pressure.
% Temperature of the mixture drops from vaporization, and using spec
% heats, can find the temperature change and then the new properties for
% the next iteration.

for n = 2:length(t)
    volumeEmptied = oxFlowRate*dt / N2O(1);
    vaporizedMass(1,n) = volumeEmptied * N2O(2);
    temp(n) = temp(n-1) - (N2O(4)*vaporizedMass(n-1) / (massLiq(n-1)*N2O(5) + massVapor(n-1)*N2O(6)));
    N2O = NitrousProperties(temp(n));
    volLiq(n) = volLiq(n-1) - volumeEmptied;
    volVapor(n) = volVapor(n-1) + volumeEmptied;
    massLiq(n) = volLiq(n)*N2O(1);
    massVapor(n) = volVapor(n)*N2O(2);
    ullage(n) = massVapor(n) / (N2O(2)*volTank);
    pressure(n) = N2O(3);
    
    if (ullage(n) >= 1) || (massLiq(n) <= 0)
        vaporPhaseTime = n;
        break
    end
end

figure;
subplot(221)
plot(t(1:vaporPhaseTime), pressure(1:vaporPhaseTime))
xlabel('Time(seconds)')
ylabel('Pressure(kPa)')
title('Pressure Drop of Nitrous Tank')

subplot(222)
plot(t(1:vaporPhaseTime), temp(1:vaporPhaseTime))
xlabel('Time(seconds)')
ylabel('Temperature(K)')
title('Temperature Drop of Nitrous Tank')

subplot(223)
plot(t(1:vaporPhaseTime), massLiq(1:vaporPhaseTime), t(1:vaporPhaseTime), massVapor(1:vaporPhaseTime))
xlabel('Time(seconds)')
ylabel('Mass(kg)')
title('Nitrous Mass in Tank')
legend('Liquid mass','Vapor mass')