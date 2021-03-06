function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)

s= 4;
sz = size(Xs);
n = sz(1);

Hbest = [];
inliersbest = [];
Mbest = 0;


for it = 1:1: ransac_n
    u = [];
    while length(u) ~= s
        ids = randi(n,s,1);
        u = unique(ids);
    end
    
    src_pts_nx2 = []; 
    dest_pts_nx2 = [];
    
    for k = 1:1:length(ids)
        src_pts_nx2 = [src_pts_nx2; Xs(ids(k),:)];
        dest_pts_nx2 = [dest_pts_nx2; Xd(ids(k),:)];
    end
    
    H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2);
    
    M = 0;
    inliers = [];
    for l = 1:1:n
        v = H_3x3*[Xs(l,:),1]';
        v(1) = v(1)/v(3);
        v(2) = v(2)/v(3);
        if norm(Xd(l,:)-[v(1), v(2)]) <= eps
            M = M+1;
            inliers = [inliers, l];    
        end
        
    end
    
    if M > Mbest
        Mbest = M;
        inliersbest = inliers;
        Hbest = H_3x3;
    end
    
    
end


inliers_id = inliersbest;
H = Hbest;