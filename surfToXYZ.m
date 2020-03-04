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
% Conditional:
% (x, y ,z) = (-1, 0, 0) is ignored
% To be fixed ^

    [mx, nx] = size(x);
    [my, ny] = size(y);
    [mz, nz] = size(zMap);
    X = zeros(mz*nz, 1);
    Y = zeros(nz*mz, 1);
    Z = zeros(mz*nz, 1);
    
    for row = 1:mz
        for col = 1:nz
%             if ( x(row, 1)==-1 & y(col, 1)==0 & zMap(row, col)==0)
%                 X(row*col, :) = [];
%                 Y(row*col, :) = [];
%                 Z(row*col, :) = [];
%                 continue
%             end
            X(row*col, 1) = x(row, col);
            Y(row*col, 1) = y(row, col);
            Z(row*col, 1) = zMap(row, col);
        end
    end
    
end