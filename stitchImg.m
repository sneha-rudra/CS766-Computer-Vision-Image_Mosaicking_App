function stitched_img = stitchImg(varargin)



imgc = im2double(varargin{1});
for i = 2:2:length(varargin)-1
    imgl = varargin{i};
    imgr = varargin{i+1};
    imgc = stitch(imgc, imgl, imgr);
end

stitched_img = imgc;
return;




function imgc = stitch(imgc, imgl, imgr)

[xcl, xl] = genSIFTMatches(imgc, imgl);
[xcr, xr] = genSIFTMatches(imgc, imgr);

sz1 = size(xl);
n1 = sz1(1);
sz2 = size(xr);
n2 = sz2(1);

ransac_n = max(n1,n2)/2;
ransac_eps = 1.0;

[inliersId_lc, H_lc] = runRANSAC(xl, xcl, ransac_n, ransac_eps);
[inliersId_rc, H_rc] = runRANSAC(xr, xcr, ransac_n, ransac_eps);

szl = size(imgl);
lb = [1,1; szl(2),1; szl(2), szl(1); 1, szl(1)];
lrb = applyHomography(H_lc, lb);


szr = size(imgr);
rb = [1,1; szr(2),1; szr(2), szr(1); 1, szr(1)];
rrb = applyHomography(H_rc, rb);


Lx = round(min(lrb(:,1)));
Rx = round(max(rrb(:,1)));

Lyn = round(min(lrb(:,2)));
Ryn = round(min(rrb(:,2)));
minyn = min(Lyn, Ryn);

Lyp = round(max(lrb(:,2)));
Ryp = round(max(rrb(:,2)));
maxyp = max(Lyp, Ryp);

rif = imgc;
szc = size(imgc);
maskc = ones(szc(1),szc(2));

if Lx < 0
    % pad with zeros
    rif = [zeros(szc(1),-Lx,3), rif];
    maskc = [zeros(szc(1), -Lx), maskc];
end



if Rx > szc(2)
    rif = [rif, zeros(szc(1) , Rx - szc(2) ,3)];
    maskc = [maskc, zeros(szc(1), Rx- szc(2))];
end



if minyn < 0
    rif = [zeros(-minyn,size(rif,2),3) ; rif];
    maskc = [zeros(-minyn, size(maskc,2)) ; maskc];
end



if maxyp > szc(1)
    rif = [rif; zeros(maxyp-szc(1),size(rif,2),3)];
    maskc = [maskc; zeros(maxyp-szc(1) , size(maskc,2))];
end


[rixl, xl] = genSIFTMatches(rif, imgl);
[rixr, xr] = genSIFTMatches(rif, imgr);
[inliersId_lri, H_lri] = runRANSAC(xl, rixl, ransac_n, ransac_eps);
[inliersId_rri, H_rri] = runRANSAC(xr, rixr, ransac_n, ransac_eps);
bds = [size(rif,2), size(rif,1)];
[maskl, leftim] = backwardWarpImg(imgl, inv(H_lri), bds);
[maskr, rightim] = backwardWarpImg(imgr, inv(H_rri), bds);
maskl(isnan(maskl)) = 0;
maskr(isnan(maskr)) = 0;


maskcl = maskc + maskl; maskcl(maskcl > 0) = 1;maskcl(isnan(maskcl)) = 0;
imglc = blendImagePair(leftim, maskl, rif, maskc, 'blend'); imglc(isnan(imglc)) = 0;
imglcr = blendImagePair(rightim, maskr, imglc, maskcl, 'blend'); imglcr(isnan(imglcr)) = 0;
imgc = imglcr;
return;






