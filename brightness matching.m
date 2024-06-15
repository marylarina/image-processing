clear all;
close all;

I1 = rgb2gray(im2double(imresize(imread('br1ret.jpg'), 0.5)));
I2 = rgb2gray(im2double(imresize(imread('br2ret.jpg'), 0.5)));

figure; imshow(I1); title('Первое изображение');
figure; imshow(I2); title('Второе изображение');

[J1_1, J2_2] = myfunc(I1, I2);

figure; imshow(J1_1); title('Первое согласованное изображение');
figure; imshow(J2_2); title('Второе согласованное изображение');

function [J1_1, J2_2] = myfunc(I1, I2)

gams = 0.5 : 0.05 : 1.5;
ks = 0.5 : 0.05 : 2;

min_err = 1000;
best_gam = 1;
best_k = 1;
for gam_ = gams
    for k_ = ks
        % Выполняем гамма коррекцию с параметрами gam_ и k_
        J1 = k_ * I1 .^ gam_;
        J2 = k_ * I2 .^ gam_;
        % Средние значения яркости
        mJ1 = mean2(J1);     % средняя яркость опорного изображения
        mJ2 = mean2(J2);      % средняя яркость подгоняемого изображения с параметрами gam_ и k_
        err = abs(mJ1 - mJ2); % разница средних яркостей
        if err < min_err        % если ошибка меньше последнего лучшего значения
            % фиксируем параметры гамма-коррекции
            min_err = err;
            best_gam = gam_;
            %best_k = k_;
        end
    end
end

res1 = best_k * I1 .^ best_gam;
res2 = best_k * I2 .^ best_gam;

J1_1 = multiscale_retinex(res1);
J2_2 = multiscale_retinex(res2);

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