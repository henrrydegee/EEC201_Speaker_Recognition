function [X, Y, Z] = surfToXYZ(x, y, zMap)
% surfToXYZ unrolls a zMap Matrix according to its
% x-y coordinate into a column vector
% Inputs:
% x - m*1 Matrix
% y - n*1 Matrix
% z - m*n Matrix
% Outputs:
% X - (m*n)*1 Matrix
% Y - (n*m)*1 Matrix
% Z - (m*n)*1 Matrix

    [mx, nx] = size(x);
    [my, ny] = size(y);
    [mz, nz] = size(zMap);
    X = zeros(mx*my, 1);
    Y = zeros(my*mx, 1);
    Z = zeros(mz*nz, 1);
    
    for row = 1:mz
        for col = 1:nz
            X(row*col, 1) = x(row, 1);
            Y(row*col, 1) = y(col, 1);
            Z(row*col, 1) = zMap(row, col);
        end
    end
    
end