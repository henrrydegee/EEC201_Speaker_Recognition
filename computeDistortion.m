function distortion = computeDistortion(X, idx, centroids, K)
% Computes the distortion around the cluster assigned
    distortion = 0;
    for clster = 1:K
        sel = find(idx == clster);
        diff = bsxfun(@minus, X(sel, :), centroids(clster,:));
        distortion = distortion + sum(diff.^2, 'all');
    end
    distortion = distortion ./ size(X, 1);
end