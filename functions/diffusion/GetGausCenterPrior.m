function gausCenterPrior = GetGausCenterPrior(height, width)

h = height;
w = width;

[x y] = meshgrid(-w/2+1:w/2, -h/2+1:h/2); 
x = x.^2;
y = y.^2;
c = 3;
% gausCenterPrior = zeros(1,sup.num);
% for ix = 1 : sup.num
%     temp_x_dist = mean(x(cell2mat(sup.pixIdx(ix))));
%     temp_y_dist = mean(y(cell2mat(sup.pixIdx(ix))));
%     gausCenterPrior(1,ix) = exp(-c^2*temp_x_dist/w^2 - c^2*temp_y_dist/h^2);
% end

gausCenterPrior = exp(-c^2*x/w^2 - c^2*y/h^2);