function plotDistort(distort_compare)
    % Plots the distortion on scatter plot
    figure; scatter(1:11, distort_compare);
    xlabel('Speaker index'); ylabel('Distorition');
    title('Distortion across speaker indices');
    ylim([min(distort_compare), max(distort_compare)]);
    grid on;
end