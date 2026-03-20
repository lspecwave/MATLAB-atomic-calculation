function p = npg(m)
if nargin < 1
    m = size(get(gcf, 'colormap'), 1); 
end

% https://github.com/nanxstats/ggsci/blob/master/data-raw/data-generator.R
% hex2dec(["E6" "4B" "35"])/255
cmap_mat = [
    0.9020    0.2941    0.2078 % Cinnaba, '#E64B35'
    0.3020    0.7333    0.8353 % Shakespeare, '#4DBBD5'
         0    0.6275    0.5294 % PersianGreen, '#00A087'
    0.2353    0.3294    0.5333 % Chambray, '#3C5488'
    0.9529    0.6078    0.4980 % Apricot, '#F39B7F'
    0.5176    0.5686    0.7059 % WildBlueYonder, '#8491B4'
    0.5686    0.8196    0.7608 % MonteCarlo, '#91D1C2'
    0.8627         0         0 % Monza, '#DC0000'
    0.4941    0.3804    0.2824 % RomanCoffee, '#7E6148'
    0.6902    0.6118    0.5216 % Sandrift, '#B09C85'
    ];

if m > 1 && m <= size(cmap_mat, 1)
    p = cmap_mat(1:m, :);
end


if m > size(cmap_mat, 1)
    xin = linspace(0, 1, m)';
    xorg = linspace(0, 1, size(cmap_mat, 1));
    p(:, 1) = interp1(xorg, cmap_mat(:,1), xin, 'linear');
    p(:, 2) = interp1(xorg, cmap_mat(:,2), xin, 'linear');
    p(:, 3) = interp1(xorg, cmap_mat(:,3), xin, 'linear');
end


end