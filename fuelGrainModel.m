%% Version 2.1.1
%% Step 1
img = imread('./Grains/doubleDoubleAnchor.tif'); % Reads image and saves as variable
img = imclearborder(img);
imshow(img);
nPixX = size(img,1);
nPixY = size(img,2);
W = 50; % mm
H = 50; % mm
dx = W/nPixX; % mm of the width of each pixel
dy = H/nPixY; % mm of the height of each pixel
rDot = 3; % Burn Regression
rDotPix = rDot/dx; % Regression in pixels
stepSize = .25; % How many seconds per step
burnTime = 10; % sec
reg = rDotPix*stepSize; 
steps = burnTime/stepSize;
xPlot = 1:1:steps;
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
figure
plot(xPlot,P);
title("Perimeter")
xlabel("Time");
ylabel("Perimeter (mm)");
figure
plot(xPlot,A)
title("Area")
xlabel("Time");
ylabel("Area (mm^2)");

function [X,Y] = plotBoundary(bwImg)
outline = bwboundaries(bwImg);
figure(1)
hold on
X = outline{1}(:, 2);
Y = outline{1}(:, 1);
plot(X, Y, 'r-', 'LineWidth', 1,'Color','y');
hold off;
end

function b = binary(img,t) % input: image and threshold value
imgG = mat2gray(img); % Changes image to grayscale from 0 (black) to 1 (white)
b = imgG>t; % Changes any pixels greater than our threshold value to 1 (white), and the rest to 0 (black)
end
