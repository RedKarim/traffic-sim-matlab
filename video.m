v = videoWriter('A.avi');
v.FrameRate = 2;
open(v);
for I = 1:length(M)
  writeVideo(v, M(I));
endfor
close(v);
