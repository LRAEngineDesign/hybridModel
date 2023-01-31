clear all;

answer = questdlg("Do you have a screenshot or a black and white image?",'Selection','SS','BW','SS');
file = imgetfile;
img = imread(file); % Reads image and saves as variable
if answer == "SS"
img = imbinarize(imadjust(rgb2gray(img)));
img = imfill(img);
end
%% Step 1

prompt = {'Heigth and Width (mm): ','Regression Rate (mm/s):','Step Size (s):','Burn Time (s)'};
dlgtitle = 'Inputs';
dims = [1 20];
definp = {'50', '2', '1', '10'};
inputs = inputdlg(prompt,dlgtitle,dims,definp);
inputs = str2double(inputs);

img = imclearborder(img);
imshow(img);
nPixX = size(img,1);
nPixY = size(img,2);
W = inputs(1); % mm
H = inputs(1); % mm
dx = W/nPixX; % mm of the width of each pixel
dy = H/nPixY; % mm of the height of each pixel
rDot = inputs(2); % Burn Regression
rDotPix = rDot/dx; % Regression in pixels
stepSize = inputs(3); % How many seconds per step
burnTime = inputs(4); % sec
reg = rDotPix*stepSize; 

steps = burnTime/stepSize;
xPlot = linspace(1,burnTime,steps);
P = zeros(1,steps);
A = zeros(1,steps);

%% Step 2
figure(1) % Opens figure
hold on
axis on % Shows axes
hold off
%% Step 3
bwimg = binary(img,0); % Converts image from grayscale to binary
[X,Y] = plotBoundary(bwimg); % Plots the initial outline
P(1) = sum( sqrt((diff(X)*dx).^2 + (diff(Y)*dy).^2));
A(1) = sum(bwimg,"all");
img = bwimg*255; % Converts image back to grayscale
%% Step 4
h = fspecial("disk",reg); % Creates disk filter with radius
for i = 1:steps % Iterates 100 times
%% Step 5
imgBlur = imfilter(img,h); % Blurs image using disk filter
%% Step 6
bwimg = binary(imgBlur,.1); % Changes gray pixels to white pixels, with certain % thresholding
%% Step 7
[X,Y] = plotBoundary(bwimg); % Plots outline of new image
P(i) = sum( sqrt((diff(X)*dx).^2 + (diff(Y)*dy).^2));
A(i) = sum(bwimg,"all")*dx*dy;
img = bwimg*255; % Converts back to grayscale
end
dA = diff(A)./diff(xPlot);
%fixing Andres' jank af units
dA = dA*1e-6;
lengthCC = 0.3; %chamber length 300 mm, 12";
dV = lengthCC*dA;

rhoHTPB = 0.902*1000; %g/cm^3 == ml
%1 g/cm^3 = 1e-6 kg/mm^3

mdot_f = dV*rhoHTPB;

%% 
figure('Name','Output Data','NumberTitle','off');
subplot(2,2,1)
plot(xPlot,P);
grid on
title("Perimeter vs Time");
xlabel("Time (s)");
ylabel("Perimeter (mm)");
Pavg = mean(P);
yline(Pavg,'--');
gravstr = sprintf('P_{avg} = %.1f',Pavg);
legend('P',gravstr);


subplot(2,2,2)
plot(xPlot,A)
grid on
title("Area vs Time")
xlabel("Time (s)");
ylabel("Area (mm^2)");
Aavg = mean(A);
yline(Aavg,'--');
gravstr = sprintf('A_{avg} = %.1f',Aavg);
legend('A',gravstr);


subplot(2,2,3);
plot(xPlot(2:end),mdot_f);
grid on
title('mdot_f vs Time');
ylabel('$\dot{m_f}$ (kg/s)', 'Interpreter','latex');
xlabel('Time (s)');
mdot_f_avg = mean(mdot_f);
yline(mdot_f_avg,'--');
%legend('$\dot{m_f,avg}$ (kg/s)','mdot_avg', 'Interpreter','latex');
gravstr = sprintf('${m_{f,avg}}$ = %.4f',mdot_f_avg);
legend('$\dot{m_{f,avg}}$  (kg/s)',gravstr,'Interpreter','latex');
%need to add an average m_dot average. 


%% Step 8 Apporoximating mdot_o 
%designing to be around a constant oxidizer flux. 
OF = 6.5;
%min case (initial combustion)
mdot_f_min = mdot_f(1);
mdot_o_min = OF*mdot_f_min;

%max case (final)
mdot_f_max = mdot_f(end);
mdot_o_max = OF*mdot_f_max;

%using mdotf average; 
%average 
%OF 
mdot_f_average = mean(mdot_f);
for i = 1:steps-1
    mdot_o_average(i) = OF*mdot_f_average;
end 
mdot_total = mdot_f+mdot_o_average;

%shifting OF
OFshifting = mdot_o_average./mdot_f;
for i = 1:steps-1
    OFshifting_average(i) = mean(OFshifting);
end 

%
subplot(2,2,4)

yyaxis left
plot(xPlot(2:end),mdot_total,'-m',xPlot(2:end),mdot_f,'-c',xPlot(2:end),mdot_o_average,'-b');
ylabel('$\dot{m}$ (kg/s)', 'Interpreter','latex');
yyaxis right
plot(xPlot(2:end),OFshifting,"Color","#D95319");
ylabel('O/F');
yline(OFshifting_average,'--');
grid on
title('mdot_{tot}, OF, mdot_o, mdot_f vs Time');
xlabel('Time (s)')
OFshifting_average_legend = mean(OFshifting_average);
gravstr = sprintf('${OF_{avg}}$ = %.3f ',OFshifting_average_legend);
legend('$\dot{m_{tot}}$','$\dot{m_f}$','$\dot{m_o}$','Shifting OF',gravstr, 'Interpreter','latex');

% should have this for min and max founds for acceptable OF ratio 
% yline([ymax ymin],'--',{'Max','Min'})
% 
% https://au.mathworks.com/help/matlab/ref/yline.html

%while 
file = num2str(file)
file_trim = file(1:strfind(file,'.')-1)
%while 1
%    if strfind(file_trim,'\')==''
%        break;
%    end
%    file_trim = file_trim(strfind(file,'\'):end)
%end
%  file_trim = str(1:strfind(str,'/')-1)
%   break

%filename = file+stepSize+burnTime+date+".csv"
filename=date+".csv"
Mat=[mdot_total;mdot_f;mdot_o_average];
%[n,m]=size(Mat);
writematrix(Mat,filename)

%The above code will write the data for mdot total, mdot initial, mdot
%final, shifting Oxidizer-Fuel Ratio, and Oxidizer-Fuel Ratio final into a
%excel file

%Note;
% you will get a different OF ratio based on the amount of time you run this calculator for. 
% ie, if you run for 3 seconds, it finds mdot_o based on average mdot_f, therefore average is lower if you run for a small amount 
%     of time. Only run to completion for accurateish things. 
%     







function [X,Y] = plotBoundary(bwImg)
outline = bwboundaries(bwImg);
figure(1)
hold on
if size(outline,1)>1
    for n = 1:size(outline,1)
        X = outline{n}(:, 2);
        Y = outline{n}(:, 1);
        plot(X, Y, 'r-', 'LineWidth', 1,'Color','y');
    end
else
    X = outline{1}(:, 2);
    Y = outline{1}(:, 1);
    plot(X, Y, 'r-', 'LineWidth', 1,'Color','y');
end
hold off
end

function b = binary(img,t) % input: image and threshold value
imgG = mat2gray(img); % Changes image to grayscale from 0 (black) to 1 (white)
b = imgG>t; % Changes any pixels greater than our threshold value to 1 (white), and the rest to 0 (black)
end
