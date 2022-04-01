function varargout = rsvd_compare_rgb(file_path)
%-------------------------------------------------------------------------------------
% MATH 123 project script for RGB images without HOSVD
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

X = double(imread([im_name,im_format]))/(2^bits);
R = X(:,:,1);
G = X(:,:,2);
B = X(:,:,3);

k = 250;

%% SVD
tic; 
% Compute the deterministic SVD of X
[UR,SR,VR] = svd(R,'econ');

% Compute the deterministic SVD of X
[UG,SG,VG] = svd(G,'econ');

% Compute the deterministic SVD of X
[UB,SB,VB] = svd(B,'econ');

svd_construction = cat(3,...
    UR(:,1:k)*SR(1:k,1:k)*VR(:,1:k)',...
    UG(:,1:k)*SG(1:k,1:k)*VG(:,1:k)',...
    UB(:,1:k)*SB(1:k,1:k)*VB(:,1:k)');

t.det = toc;

%% rSVD
tic; 
% Compute the random SVD on R component
[rUR,rSR,rVR] = rsvd(R,k,15,1);

% Compute the random SVD on G component
[rUG,rSG,rVG] = rsvd(G,k,15,1);

% Compute the random SVD on B component
[rUB,rSB,rVB] = rsvd(B,k,15,1);

rsvd_construction = cat(3,...
    rUR*rSR*rVR',...
    rUG*rSG*rVG',...
    rUB*rSB*rVB');

t.rsvd = toc;

%% Write the new image files
if bits == 16
    imwrite(im2uint16(svd_construction),[im_name,'svd_rgb',im_format]);
    imwrite(im2uint16(rsvd_construction),[im_name,'rsvd_rgb',im_format]);
else
    imwrite(im2uint8(svd_construction),[im_name,'svd_rgb',im_format]);
    imwrite(im2uint8(rsvd_construction),[im_name,'rsvd_rgb',im_format]);
end

%% Output
if(nargout > 0), varargout{1} = t; varargout{2} = err; end

end