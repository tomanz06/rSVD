function varargout = rsvd_compare_grayscale(file_path)
%-------------------------------------------------------------------------------------
% MATH 123 project script
%
% usage : 
%
%  input:
%  * file : the path to the input image file to analyze
%
%  output:
%  * t : struct containing the time elapsed for each SVD computation
%  * err : struct containing the errors of each SVD to the original file
%  * writes out the SVD and rSVD images to new files
%-------------------------------------------------------------------------------------
% Thomas Anzalone and Elijah Sanderson, 2021

[im_name,im_format] = strtok(file_path,'.');

if strcmpi(im_format,'.tiff') || strcmpi(im_format,'.png')
    bits = 16;
else
    bits = 8;
end

X = double(rgb2gray(imread([im_name,im_format])))/(2^bits);

k = 300;

% Compute the deterministic SVD of X
tic; [U,S,V] = svd(X,'econ'); t.det = toc;

% rSVD #1 - Compute the random SVD with no techniques
tic; [rU1,rS1,rV1] = rsvd(X,k); t.rsvd1 = toc;

% rSVD #2 - Compute the random SVD with just oversampling the intrinsic rank by 5
tic; [rU2,rS2,rV2] = rsvd(X,k,20); t.rsvd2 = toc;

% rSVD #3 - Compute the random SVD with oversampling the intrinsic rank by 5 and doing 2 power iterations
tic; [rU3,rS3,rV3] = rsvd(X,k,20,1); t.rsvd3 = toc;

% Observe the errors in each method from the actual image
err.det = norm(X-U(:,1:k)*S(1:k,1:k)*V(:,1:k)',2)/norm(X,2);
err.rsvd1 = norm(X-rU1*rS1*rV1',2)/norm(X,2);
err.rsvd2 = norm(X-rU2*rS2*rV2',2)/norm(X,2);
err.rsvd3 = norm(X-rU3*rS3*rV3',2)/norm(X,2);

%% Write the new image files
if bits == 16
    imwrite(im2uint16(U(:,1:k)*S(1:k,1:k)*V(:,1:k)'),[im_name,'svd',im_format]);
    imwrite(im2uint16(rU1*rS1*rV1'),[im_name,'rsvd1',im_format]);
    imwrite(im2uint16(rU2*rS2*rV2'),[im_name,'rsvd2',im_format]);
    imwrite(im2uint16(rU3*rS3*rV3'),[im_name,'rsvd3',im_format]);
else
    imwrite(im2uint8(U(:,1:k)*S(1:k,1:k)*V(:,1:k)'),[im_name,'svd',im_format]);
    imwrite(im2uint8(rU1*rS1*rV1'),[im_name,'rsvd1',im_format]);
    imwrite(im2uint8(rU2*rS2*rV2'),[im_name,'rsvd2',im_format]);
    imwrite(im2uint8(rU3*rS3*rV3'),[im_name,'rsvd3',im_format]);
end

%% Output
if(nargout > 0), varargout{1} = t; varargout{2} = err; end

end