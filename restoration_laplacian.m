clear all;
close all;

I = im2double(rgb2gray(imread('Lenna.png'))); %преобразование изображение из цветного в черно-белое, потом в формат double
figure; imshow(I); title('Исходное изображение');

%J = medfilt2(I);
sig = 1;
J = imfilter(I, fspecial('gaussian', 3, sig), 'symmetric');
figure; imshow(J); title('Размытое изображение');

%Нечеткий фильтр

alphas = 0 : 0.05 : 1;
grads = alphas * 0;
for i = 1 : numel(alphas)   
    alpha = alphas(i);
    h = fspecial('unsharp', alpha);
    I_ = imfilter(J, h, 'symmetric');
    [Gx, Gy] = imgradientxy(I_, 'CentralDifference');
    G = hypot(Gx, Gy);
    grad = mean(G(:));
    disp("Alpha " + num2str(alpha) + "; mean grad " + num2str(grad));
    grads(i) = grad;
end

[max_grad, max_grad_id] = max(grads(:));
alpha = alphas(max_grad_id);
disp("The best alpha " + num2str(alpha));
h = fspecial('unsharp', alpha);
I_ = imfilter(J, h, 'symmetric');
figure; imshow(I_); title('Восстановленное изображение (unsharp)');

%Лапласиан

alphas2 = 0 : 0.05 : 1;
grads2 = alphas2 * 0;
for i = 1 : numel(alphas2)   
    alpha2 = alphas2(i);
    h = -fspecial('laplacian', alpha2);
    %h(2,2) = h(2,2) + 1;
    I_ = imfilter(J, h, 'symmetric');
    result = I_ + J;
    [Gx, Gy] = imgradientxy(result, 'CentralDifference');
    G = hypot(Gx, Gy);
    grad2 = mean(G(:));
    disp("Alpha " + num2str(alpha2) + "; mean grad " + num2str(grad2));
    grads2(i) = grad2;
end

[max_grad2, max_grad_id2] = max(grads2(:));
alpha2 = alphas2(max_grad_id2);
disp("The best alpha " + num2str(alpha2));
h = -fspecial('laplacian', alpha2);
%h(2,2) = h(2,2) + 1;
I_ = imfilter(J, h, 'symmetric');
res = I_ + J;
figure; imshow(res); title('Восстановленное изображение (laplacian)');