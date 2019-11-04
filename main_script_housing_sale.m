%% Data cleansing/merging/appending
% Multiple linear regression to estimate different home factors response 
% with time-series data for all types of homes

workpath = 'C:\Google Drive Sync\Ms O\Job App\Industry job\Data Incubator\Project\working\';

%% X factor 1: Number of bedrooms = 1 ~ 5+
y_col = [10, 13, 14, 15];
x_col = [3, 11];
c_col = [4, 12];
flnm_key = 'Bed';
Bed_data_now = multi_regression(workpath, y_col, x_col, c_col,flnm_key);

%% X factor 2: Home type = Single Family Residence or Condo

flnm_key = 'Type';
Type_data_now = multi_regression(workpath, y_col, x_col, c_col,flnm_key);

%% X factor 3: Price Tier = Top or bottom one-third.
y_col = [10, 17];
x_col = [3, 14];
c_col = [4, 12];
flnm_key = 'Tier';
Tier_data_now = multi_regression(workpath, y_col, x_col, c_col,flnm_key);

%% Y: Listing Price cut % by property Type: 

flnm_key = 'ListCutType';
LstCtType_data_now = multi_regression(workpath, y_col, x_col, c_col,flnm_key);

%% Y: Listing Price cut % by Price tier: 

flnm_key = 'ListCutTier';
LstCtTier_data_now = multi_regression(workpath, y_col, x_col, c_col,flnm_key);

%% Load reshaped data matrices for MLNN training

load('MLdata.mat');
% Region ID; #ofBedrooms; SFR/Condo; List price; List price per sqft
X = num(:,[3,11,19,25,26]);
% days; StoLration; pricecut%; listing cut percentage
Y = num(:,[27:30]);

%% Run Machine learning - Neural networks training 

% Setup the parameters 
input_layer_size  = 5;    % Region ID; #ofBedrooms; SFR/Condo; List price; List price per sqft
hidden_layer_size = 3;    % 25 hidden units
num_labels = 1;        % # of labels for Y 

for nn = 1:size(Y,2)
    y = Y(:,1);
    m = size(X, 1);
    
    sel = randperm(size(X, 1));
    sel = sel(1:100);
    % Weight regularization parameter (we set this to 0 here).
    lambda = 0;
    J = nnCostFunction(nn_params, input_layer_size, hidden_layer_size, num_labels, X, y, lambda);

    % Initializing Pameters 
    initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
    initial_Theta2 = randInitializeWeights(hidden_layer_size, num_lbl);
    % Unroll parameters
    initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

    % Implement Regularization
    lambda = 3;
    checkNNGradients(lambda);

    % Also output the costFunction debugging values
    nn_params = initial_nn_params;
    debug_J  = nnCostFunction(nn_params, input_layer_size, hidden_layer_size, num_lbl, X, y, lambda);

    % Training Neural Networks
    options = optimset('MaxIter', 50);
    lambda = 1;

    % Create "short hand" for the cost function to be minimized
    costFunction = @(p) nnCostFunction(p, input_layer_size, hidden_layer_size, num_lbl, X, y, lambda);
    [nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

    % Obtain Theta1 and Theta2 back from nn_params
    Theta1(:,:,nn) = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), hidden_layer_size, (input_layer_size + 1));
    Theta2(:,:,nn) = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), num_lbl, (hidden_layer_size + 1));
end

%% Implement Predict
% input property infmation for prediction

% X(1) = zip code; X(2) = # of bedroom; X(3) = 1(condo); X(4) = list price; X(5) = sqft
X_input = [16803, 3, 1, 200000, 1000]; 

pred = predict(Theta1, Theta2, X_input);













