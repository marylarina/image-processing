clear all;
close all;

%I = rgb2gray(im2double(imread('2.png')));
I = rgb2gray(im2double(imread('t3.png')));
figure; imshow(I);
J = multiscale_retinex(I);

adaptBin(I);

figure; imhist(J)
thresh = 0.6;
globalBin(J, thresh);

globalBinOts(J);

%figure; imhist(I)
%thresh = 0.6;
%globalBin(I, thresh);

%globalBinOts(I);


function adaptBin(I)
J = imbinarize(I, 'adaptive', 'Sensitivity', 0.7);
figure; imshow(J); title('Результат бинаризации');
%J = medfilt2(J, [2 2]);
%figure; imshow(J); title('Результат бинаризации после медианы');
end

function image = multiscale_retinex(I)
sigs = [4, 12, 25]; % значения СКО ядер
Ib = 0;
for sig = sigs          % суммируем изображения фона по всем СКО ядер
    h = fspecial('gaussian', 2 * fix(1.5 * sig) + 1, sig);  % гауссовское ядро
    Ib = Ib + imfilter(I, h, 'symmetric');   % изображение фона - очень размытое исходное изображение
end
Ib = Ib / numel(sigs);  % делим на число СКО (усредняем по всем масштабам)
Ib(Ib == 0) = 1/255;
% Формируем изображение переднего плана (детали)
image = log(1 + I) - log(1 + Ib);
image = (image - min(image(:))) ./ range(image(:));
end

function globalBin(I, thresh) 
J = I > thresh;
figure; imshow(J); title('Глобальная бинаризация по заданному значению порога');
end

function globalBinOts(I)
ots_thresh = graythresh(I);
disp(ots_thresh);
J = imbinarize(I, 'global');
figure; imshow(J); title('Глобальная бинаризация по оптимальному порогу (Оц)');
end