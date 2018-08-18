function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H,...
    dest_canvas_width_height)


szP = size(src_img);
sz = [dest_canvas_width_height(1) dest_canvas_width_height(2) 3];
iH = resultToSrc_H;


figure(1);
bg_img = image(ones(sz));
close(1); 

mask = uint8(zeros(dest_canvas_width_height(2), dest_canvas_width_height(1)));

for i = 1:1: sz(1)
    for j = 1:1:sz(2)
        v = [i;j;1];
        a = iH*v;
        a(1) = ceil(a(1)/a(3));
        
        a(2) = ceil(a(2)/a(3));
  
        if a(1) > 0 && a(2) > 0 && a(1) <= szP(2) &&  a(2) <= szP(1)
            bg_img(j,i,1) = src_img(a(2),a(1),1);
            bg_img(j,i,2) = src_img(a(2),a(1),2);
            bg_img(j,i,3) = src_img(a(2),a(1),3);
            mask(j,i) = 255;
        else
            bg_img(j,i,1) = 0;
            bg_img(j,i,2) = 0;
            bg_img(j,i,3) = 0;
            mask(j,i) = 0;
        end
        
    end
end


figure(1); imshow(bg_img); close(1); 
size(bg_img);
size(mask);
figure(1); imshow(mask); close(1);
result_img = bg_img;
return;


