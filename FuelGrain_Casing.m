I = 8634; %impulse in Ns
t = 6; %burntime for hybrid motors in seconds;
Ft = I/t; %thurst in Newtons
Isp = 250.5; %Isp in seconds
OF = 6;
rowf = 0.0332; %fuel density in (lb/in^3)
g = 9.81;


r0 = 0.5; %initial radius of the fuel grain in inches
rf = 1; %final port radius

%Get Mass flow Rate
mprop = Ft/((Isp)*(g)); %mass propellant flow rate kg/s
mdotf = mprop/(1+OF); %mass flow rate of the fuel kg/s
mdoto = OF*mdotf; %oxidizer flow rate kg/s

%convert to pounds
mdotf = mdotf*2.2;
mdoto = mdoto*2.2;

Lchar = (mdotf*t)/(pi*(rf^2-r0^2)*rowf);

%hoop stress calculations
Pc = 425; %combustion chamber pressure (psi) 
ri = 2.25; %combustion chamber inner radius (in)
thic = 0.125; %combustion chamber thickness (in)
hoop_stress = (Pc*(ri+thic))/thic;

material_yield_strength = 35000; %psi

SF = material_yield_strength/hoop_stress;

