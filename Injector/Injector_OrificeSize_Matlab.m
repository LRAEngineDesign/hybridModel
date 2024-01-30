mDotO = 2.33; %(kg/s) mass flow rate of injector
Cd = .70; %Discharge Coefficient
dP = 85; %(psi) change in pressure
p = 1220; %(kg/m^3)   1.22(g/cm^3) density
dP_pa = dP * 6894.76; %(Pa) pressure drop in pascal
Ao = (mDotO) / (Cd * sqrt(2 * p * dP_pa));
bitSizeInches = [1/64, 1/32, 3/64, 1/16, 5/64, 3/32, 7/64];
bitSizeDiameterM= bitSizeInches * 0.0254; 

numHoles = [0, 0, 0, 0, 0, 0, 0];
%iterates through the drill bit sizes in m
for i = 1:length(bitSizeDiameterM)
   %calculates area of the drillbit in m^2
   bitsizeArea = pi * (bitSizeDiameterM(i) ^ 2) / 4;
   %num holes for that drill bit
   N = Ao/bitsizeArea;
   %appends into list
   numHoles(i) = N;
end

disp(numHoles) %number of orifices needed