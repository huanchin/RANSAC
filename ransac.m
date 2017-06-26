rgb1 = imread('1-50.jpg');
rgb2 = imread('1-50-(2).jpg');

img1 = imresize(rgb1,0.09);
img2 = imresize(rgb2,0.09);

im1 = rgb2gray(img1);
im2 = rgb2gray(img2);

Width = size(img1,2);
Height = size(img1,1);
N = Width*Height;
display(Width);
display(Height);
display(N);
pic1 = reshape(im1,[N,1]);
pic2 = reshape(im2,[N,1]);

figure(1);
scatter(log(double(pic1)),log(double(pic2)));
hold on;
pts = log(double(cat(2,pic1,pic2))); %Nx2 Array of data(points)

%set parameters
 %number of pixels
 
iterations = 500;
thresdis = 0.75;


% output model
bestModel = [];
bestInliers = [];
bestOutliers = [];
bestIn_pos = [];
bestOut_pos = [];
bestError = inf;
best_ni = 0;
dis = [];  

for i=1:iterations
	data = pts;
    randomP = randperm(N); %returns a row vector containing a random permutation of the integers from 1 to N inclusive.
    %randomly pick 2 points
	p1 = [ data(randomP(1),1), data(randomP(1),2) ];
    p2 = [ data(randomP(2),1), data(randomP(2),2) ];
    
    inliers = [];
    outliers = [];
    
    
    a_model = double(( p1(2) - p2(2) )/ ( p1(1) - p2(1) )); %slope
    b_model = double( p1(2) - a_model*p1(1) ); %y intercept
    
    %find distance(2xN) of all the points to line
    A = [a_model;-1];
    B = ones(N,1)*b_model;
    dis = abs(double(data) * A + B) /sqrt( a_model^2 + 1);
    
    %find all the position of inliers & outliers
    in_pos = find (double(dis) <= double(thresdis));
    out_pos = find (double(dis) > double(thresdis));
    %find the total distance
    totalError = sum(dis,1); 
    %find how many poinbts are inliers
    ni = size(in_pos);
    no = size(out_pos);
    
    % check model
    
    if ( best_ni < ni )
        bestModel = [a_model,b_model];
        bestOut_pos = out_pos;
        bestIn_pos = in_pos;
        bestError_pos = totalError;
        best_ni = ni;
    end
        
       
end % main iteration end

best_no = size(bestOut_pos,1);
best_ni = N - best_no;
display(best_ni);
display(best_no);

scatter( pts( bestOut_pos , 1 ) , pts( bestOut_pos, 2 ), 40,'r');
hold on;

x = linspace(0,log(double(255)));
y = bestModel(1,1)*x + bestModel(1,2);
plot(x,y);
hold off;

img1 = reshape(img1,[124416,3]);
for i = 1:best_no
    img1(bestOut_pos(i),:) = [255,0,0];
end
img1 = reshape(img1,[Height,Width,3]);
figure(2);
imshow(img1);

img2 = reshape(img2,[124416,3]);
for i = 1:best_no
    img2(bestOut_pos(i),:) = [255,0,0];
end
img2 = reshape(img2,[Height,Width,3]);
figure(3);
imshow(img2);


return;