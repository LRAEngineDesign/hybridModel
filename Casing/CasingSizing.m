% Casing Sizing based on Brauenig and H&H Equations

% Conversion Constants
mm_to_cm = .1; 
mm2_to_cm2 = .01;

% Given nozzle throat dimensions
At = 1509.49*mm2_to_cm2; % cm^2
Rt = 21.42*mm_to_cm; % cm
Dt = 2*Rt*mm_to_cm; % cm
con_theta_est = 30; % deg

%% Deriving Chamber Dimensions from Eqns in OneNote

% Eqn derived from graph (only in cm)
Lc = exp(0.029*log(Dt)^2 + .47*log(Dt) + 1.94);

% Contraction Ratio and Chamber Area
epsilon_c = 8*(Dt)^-.6 + 1.25;
% Ac = epsilon_c*At;

% Combustion Chamber Volume
Vc = (At)*epsilon_c + 1/3*sqrt(At/pi())*cotd(con_theta_est)*(epsilon_c^(1/3) - 1);

% Chamber Diameter
Dc = 10; % cm; initial guess

error = 100;
tol = .0001;
maxit = 100;
i_save = linspace(0, maxit, maxit+1);
Dc_save = zeros(1, maxit+1);

i = 0;
while (error >= tol) && (i < maxit)
    Dc_prev = Dc;
    Dc = sqrt((Dt^3 + 24*pi()*tand(con_theta_est)*Vc)/(Dc + 6*tand(con_theta_est)*Lc));
    error = abs((Dc_prev - Dc)/Dc);
    
    Dc_save(i+1) = Dc;
    i = i + 1;
end

figure
plot(i_save, Dc_save, "o")