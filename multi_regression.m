%%
function [ data_now ] = multi_regression( workpath, y_col, x_col, c_col,flnm_key )

file_list  = dir(strcat(workpath,flnm_key,'*.csv'));
for n = 1:size(file_list,1)
    % find files > 1024 bytes to remove system files from list
    raw_file(n,1) = file_list(n).bytes > 1024;
end
[rows2dump junk] = find(raw_file==0);
file_list(rows2dump) = [];

for ff = 1:size(file_list,1)
    [d_num, d_txt, d_raw] = xlsread(strcat(workpath,file_list(ff).name));
    [c_uniq, ia, ic] = unique(d_num(:,c_col(1)));
    y_fit = zeros(size(d_num,1),numel(y_col));
    for c = 1:numel(y_col)
        for n = 1:numel(c_uniq)
            disp(strcat(string(c),'_of_',string(numel(y_col)),'_;_',string(n),'_of_',string(numel(c_uniq))));
            b_tmp = glmfit(d_num(ic == n,x_col),d_num(ic == n,y_col(c)));
            y_fit(ic == n, c) = b_tmp(1) + d_num(ic == n,x_col) * b_tmp(2:end);
        end
    end
    if ff==1
        data_aggr = [d_raw(2:end,:) num2cell(y_fit)];
    else
        data_aggr = [data_aggr; [d_raw(2:end,:), num2cell(y_fit)]];
    end
end
% Export data of latest month
full_data = data_aggr;
time_all = cell2mat(full_data(:,x_col(1)));
[row_now, ~] = find(time_all == max(time_all));
data_now = full_data(row_now,2:end);
header = [d_raw(1,2:end), strcat('Fitted_',d_raw(1,y_col))];
filename_exp = strcat(workpath,flnm_key,'_data_now', '_', datestr(now,'yymmdd_HHMMSS'),'.xlsx');
xlswrite(filename_exp,[header;data_now]);


end

