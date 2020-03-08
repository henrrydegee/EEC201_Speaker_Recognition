function tScore = tPrime(train, test, distortion_train, distortion_test)

    distError = sum((train - test).^2 , 'all') ./ size(train, 1);
    tScore = distError ./ (distortion_train + distortion_test);
    tScore = sqrt(tScore);
    
end