function dot_dot_x = fcn(x,m)

% pentru a determina componenta poziției cu care lucrez mă folosesc de
% modul

% %3==0 -> x
% %3==1 -> y
% %3==2 -> z

G = 6.6743e-11;
% aici presupun că n e mereu multiplu de 3
x_sizes = size(x);

n = x_sizes(1);
new_x = zeros(n,1);
for i=1:3:n
    
    for j=1:3:n
        if i==j
            continue
        end
        
        dist = sqrt((x(i)-x(j))^2 + (x(i + 1)-x(j + 1))^2 + (x(i + 2)-x(j +2))^2);
        new_x(i) = new_x(i) + G*m(floor(j/3)+1)*(x(j)-x(i))/((dist)^3);
        new_x(i + 1) = new_x(i + 1) + G*m(floor(j/3)+1)*(x(j + 1)-x(i + 1))/((dist)^3);
        new_x(i + 2) = new_x(i + 2) + G*m(floor(j/3)+1)*(x(j + 2)-x(i + 2))/((dist)^3);

    end
end

dot_dot_x = new_x';