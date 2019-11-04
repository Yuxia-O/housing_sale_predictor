%% Section 2 - Grid walk counting

% Configure the grid space by changing d/n/m as below: 
dim = single(4);     % Dimension "d"
n_grid = single(10);  % Number of grid line "n"
m_step = single(10);  % Number of steps "m"

% Generate a matrix storing coordinates of all grid intersetions by a given "d" and "n"
% (MATLAB uses an index starting from 1 instead of 0)
n_arr = [1:1:n_grid]';
coord_space = ones(n_grid^dim, dim,'single');
for d = 1:dim
    coord_space(:,d) = repmat(repelem(n_arr,n_grid^(dim-d)), [n_grid^(d-1) 1]);
end

% Calculate the number of accessible grids by 1-step walk for each grid.
grid_idx = zeros(size(coord_space,1),2*dim,'single');
dim_idx = n_grid.^[(dim-1):-1:0];
for s = 1:size(coord_space,1)
    grid_coord = coord_space(s,:);
    nbr_tmp = repmat(grid_coord,[d*2 1]);
    for d = 1:dim
        nbr_tmp(d*2-1:d*2,d) = [grid_coord(1,d)-1; grid_coord(1,d)+1];
    end
    [row, ~] = find(nbr_tmp<1|nbr_tmp>n_grid);
    nbr_tmp(row,:) = [];
    acc_grids(s,1) = size(nbr_tmp,1);
    idx = (nbr_tmp-1)*dim_idx' + 1;
    grid_idx(s,1:acc_grids(s,1)) = sort(idx');
end

% Select subset of coordinates for counting walks
% Purpose: Using symmetry along dimensions to reduce counting cycles.

[row_sub, ~] = find( max(coord_space,[],2) < (n_grid/2+1) );
coord_sub = coord_space(row_sub,:);
sort_tmp = sort(coord_sub,2);
[uniq_coord, ia, ic] = unique(sort_tmp,'rows');

for s = 1:size(uniq_coord,1)
    grid_coord = coord_space(row_sub(ia(s)),:);
    walk_tmp = grid_idx(row_sub(ia(s)),:);
    for m = 1:m_step
        walk_tmp = walk_tmp(walk_tmp>0);
        walk_length(1,m) = numel(walk_tmp);
        if m < m_step
            walk_tmp = (grid_idx(walk_tmp,:))';
            walk_tmp = walk_tmp(walk_tmp>0)';
        end
    end
    all_walks(ia(s),1:m_step) = walk_length;
    clear walk_length walk_tmp
end

% Fill out sub coordinate space with unique walk numbers
% all_walks_fill is the aggregated full paths of valid walks in sub coordinate space
for un = 1:size(uniq_coord,1)
    [row_un, ~] = find(ic == un);
    for unn = 1:numel(row_un)
        all_walks_fill(row_un(unn),:) = all_walks(min(row_un),:);
    end
end
output = [row_sub,double(coord_sub),all_walks_fill,ic,double(sort_tmp),all_walks];

% Extract final # of valid walks at step = m
% Calculate highest count / lowest count and its ratio
valid_walks = max(all_walks_fill,[],2);
max_walks = max(valid_walks);
min_walks = min(valid_walks);
high2low_ratio = max_walks/min_walks;
% Calculate the mean and stdev value and its ratio
mean_walks = mean(valid_walks);
std_walks = std(valid_walks);
std2mean_ratio = std_walks/mean_walks;
