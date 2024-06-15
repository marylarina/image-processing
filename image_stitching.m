
images = {};
images_grey = {};
for i = 1:6
    images{i} = imread(sprintf('camp1_2/%d.jpg', i));
    images_grey{i} = im2gray(imread(sprintf('camp1_2/%d.jpg', i)));
end

img = images{1};
imgg = images_grey{1};

for i = 2:6
    img2 = images{i};
    K = stitching(img, img2, imgg, images_grey{i});
    img = K;
    imgg = im2gray(K);
end

figure; imshow(img);


function I_ = stitching(I, J, Ig, Jg)
pts1 = detectHarrisFeatures(Ig);
pts2 = detectHarrisFeatures(Jg);

[f1,vpts1] = extractFeatures(Ig,pts1);
[f2,vpts2] = extractFeatures(Jg,pts2);

inx = matchFeatures(f1,f2);
matchedPts1 = vpts1(inx(1:numel(inx)/2,1));
matchedPts2 = vpts2(inx(1:numel(inx)/2,2));

figure; 
showMatchedFeatures(Ig,Jg,matchedPts1,matchedPts2,"montag");
title("Candidate point matches");
legend("Matched points 1","Matched points 2");

transformType = "affine";
tform = estgeotform2d(matchedPts2,matchedPts1,transformType);

J_ = imwarp(Jg, tform, "cubic", "OutputView", imref2d(size(Ig)));

figure; imshow(Ig);
figure; imshow(J_);

dx = ceil(tform.A(1, 3));
dy = ceil(tform.A(2, 3));
d_size = double([dy dx]);

out_size = size(Ig, 1:2) + d_size;
Rfixed = imref2d(out_size);
J_ = imwarp(Jg, tform, "cubic", "OutputView", Rfixed);
figure; imshow(J_);

mask_on_I = J_ > 0;

I_ = padarray(Ig, d_size, 0, "post");

I_(mask_on_I) = 0;

I_(mask_on_I) = J_(mask_on_I);
figure; imshow(I_)

J_ = imwarp(J, tform, "cubic", "OutputView", Rfixed);

mask_on_I_3d = J_ > 0;

I_ = padarray(I, d_size, 0, "post");

I_(mask_on_I_3d) = J_(mask_on_I_3d);
figure; imshow(I_)
end