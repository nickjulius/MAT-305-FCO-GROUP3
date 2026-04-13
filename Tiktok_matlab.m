%% LOAD DATA
data = readtable('TIKTOK_DATA.xlsx');

%% CREATE VARIABLE MEANS
% Make sure column names MATCH exactly in Excel

PU_mean = mean(data{:, {'PU1','PU2','PU3','PU4','PU5'}}, 2, 'omitnan');
TRUST_mean = mean(data{:, {'T1','T2','T3'}}, 2, 'omitnan');
PROMOTION_mean = mean(data{:, {'P1','P2','P3','P4'}}, 2, 'omitnan');
CONSUMER_mean = mean(data{:, {'C1','C2','C3','C4'}}, 2, 'omitnan');
SI_mean = mean(data{:, {'SI1','SI2'}}, 2, 'omitnan');
PI_mean = mean(data{:, {'PI1','PI2','PI3','PI4'}}, 2, 'omitnan');

%% DESCRIPTIVE STATISTICS
fprintf('\n=== DESCRIPTIVE STATISTICS ===\n');

variables = [PU_mean TRUST_mean PROMOTION_mean CONSUMER_mean SI_mean PI_mean];
varNames = {'PU','TRUST','PROMOTION','CONSUMER','SOCIAL IMPACT','PURCHASE INTENTION'};

for i = 1:length(varNames)
    fprintf('%s: Mean = %.3f | Std = %.3f\n', ...
        varNames{i}, mean(variables(:,i), 'omitnan'), std(variables(:,i), 'omitnan'));
end

%% MULTIPLE LINEAR REGRESSION

X = [PU_mean TRUST_mean PROMOTION_mean CONSUMER_mean SI_mean];

% Remove rows with NaN (VERY IMPORTANT)
validRows = all(~isnan([X PI_mean]), 2);
X = X(validRows,:);
Y = PI_mean(validRows);

% Add intercept
X = [ones(size(X,1),1) X];

% Run regression
[b, bint, r, rint, stats] = regress(Y, X);

%% DISPLAY REGRESSION RESULTS

fprintf('\n=== REGRESSION RESULTS ===\n');

fprintf('Intercept: %.4f\n', b(1));
fprintf('PU: %.4f\n', b(2));
fprintf('TRUST: %.4f\n', b(3));
fprintf('PROMOTION: %.4f\n', b(4));
fprintf('CONSUMER: %.4f\n', b(5));
fprintf('SOCIAL IMPACT: %.4f\n', b(6));

fprintf('\nR-squared: %.3f\n', stats(1));
fprintf('F-statistic: %.3f\n', stats(2));
fprintf('p-value: %.5f\n', stats(3));

%% COEFFICIENT TABLE

fprintf('\n=== COEFFICIENTS TABLE ===\n');
disp(mdl.Coefficients)

%% MODEL SUMMARY

fprintf('\n=== MODEL SUMMARY ===\n');

% Recreate validRows (so it always exists)
validRows = all(~isnan([PU_mean TRUST_mean PROMOTION_mean CONSUMER_mean SI_mean PI_mean]), 2);

% Clean data again
X_clean = [PU_mean(validRows) TRUST_mean(validRows) PROMOTION_mean(validRows) CONSUMER_mean(validRows) SI_mean(validRows)];
Y_clean = PI_mean(validRows);

% Fit model
mdl = fitlm(X_clean, Y_clean, ...
    'VarNames', {'PU','TRUST','PROMOTION','CONSUMER','SI','PI'});

% Predictions
y_pred = predict(mdl);
y_actual = Y_clean;

% Compute R^2
SS_res = sum((y_actual - y_pred).^2);
SS_tot = sum((y_actual - mean(y_actual)).^2);
R2 = 1 - (SS_res / SS_tot);

% Adjusted R^2
n = length(y_actual);
p = 5;
Adj_R2 = 1 - (1 - R2)*(n - 1)/(n - p - 1);

% R and RMSE
R = sqrt(R2);
RMSE = sqrt(mean((y_actual - y_pred).^2));

fprintf('R: %.3f\n', R);
fprintf('R^2: %.3f\n', R2);
fprintf('Adjusted R^2: %.3f\n', Adj_R2);
fprintf('Std Error (RMSE): %.3f\n', RMSE);