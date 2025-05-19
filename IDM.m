function [acc] = IDM(Xh, Vh, Xp, Vp)
T = 1.3;
Vd = 14;
S0 = 2;
if(Xh<930 && Xh>700)  
    S0 = 2;
end
a = 2;
b = 2.5;
L = 4;
DXh = Xp - Xh - L;
if(DXh<2)DXh=2; end
Rd = S0 + Vh * T + (Vh * (Vh - Vp)) / (2 * (a * b) ^ 0.5);
acc = a * (1 - (Vh / Vd) ^ 4 - (Rd / DXh) ^ 2);

if(acc<-5) acc=-5; end

end

