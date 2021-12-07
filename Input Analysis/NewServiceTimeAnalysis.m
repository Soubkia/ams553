%% Initialization
data24 = readtable('Input Analysis Data 24 core.csv');    % Read in 24 core data file
servicetimes24 = table2array(data24(:,9));
core24 = [];

data28 = readtable('Input Analysis Data 28 core.csv');    % Read in 28 core data file
servicetimes28 = table2array(data28(:,9));
core28 = [];

data40 = readtable('Input Analysis Data 40 core.csv');    % Read in 40 core data file
servicetimes40 = table2array(data40(:,9));
core40 = [];

datagpu = readtable('Input Analysis Data gpu.csv');    % Read in gpu data file
servicetimesgpu = table2array(datagpu(:,9));
gpu = [];

% Remove data points whose service times are too small
for i=1:length(servicetimes24)
    if servicetimes24(i) > 0.12          % Minimum service of 7.2 minutes
        core24 = [core24, servicetimes24(i)];
    end
end

for i=1:length(servicetimes28)
    if servicetimes28(i) > 0.07      % Minimum service of 4.2 minutes
        core28 = [core28, servicetimes28(i)];
    end
end

for i=1:length(servicetimes40)
    if servicetimes40(i) > 0.04     % Minimum service of 2.4 minutes
        core40 = [core40, servicetimes40(i)];
    end
end

for i=1:length(servicetimesgpu)
    if servicetimesgpu(i) > 0.02   % Minimum service of 1.2 minutes
        gpu = [gpu, servicetimesgpu(i)];
    end
end
%% 24 core Analysis
figure                      % Initial histogram of data
histogram(core24,100);
title('24 core Partition');

x24 = transpose(core24);
pd24 = fitdist(x24,'kernel','kernel','epanechnikov');   % Fit kernel distribution

figure
qqplot(x24,pd24);              % Create QQ plot from kernel distribution
title('24 Core QQ');

[h24,p24,stats24] = chi2gof(x24,'CDF',pd24);   % Perform chi-squre test

x_values24 = 0:0.1:160;        
y24 = pdf(pd24,x_values24);      % Create sample distribution data

figure
histogram(core24,100,'normalization','pdf');  % Plot fitted histogram
hold on 
plot(x_values24,y24,'linewidth',2);
xlabel('Service Time (Hours)');
ylabel('Normalized Frequency');
title('24 Core Fit');


%% 28 core Analysis
figure                      % Initial histogram of data
histogram(core28,100);
title('28 core Partition');

x28 = transpose(core28);
pd28 = fitdist(x28,'kernel','kernel','epanechnikov');   % Fit kernel distribution

figure
qqplot(x28,pd28);              % Create QQ plot from kernel distribution
title('28 Core QQ');

[h28,p28,stats28] = chi2gof(x28,'CDF',pd28);   % Perform chi-squre test

x_values28 = 0:0.1:160;        
y28 = pdf(pd28,x_values28);      % Create sample distribution data

figure
histogram(core28,100,'normalization','pdf');  % Plot fitted histogram
hold on 
plot(x_values28,y28,'linewidth',2);
xlabel('Service Time (Hours)');
ylabel('Normalized Frequency');
title('28 Core Fit');

%% 40 Core Analysis
figure                      % Initial histogram of data
histogram(core40,100);
title('40 core Partition');

x40 = transpose(core40);
pd40 = fitdist(x40,'kernel','kernel','epanechnikov');   % Fit kernel distribution

figure
qqplot(x40,pd40);              % Create QQ plot from kernel distribution
title('40 Core QQ');

[h40,p40,stats40] = chi2gof(x40,'CDF',pd40);   % Perform chi-squre test

x_values40 = 0:0.1:160;        
y40 = pdf(pd40,x_values40);      % Create sample distribution data

figure
histogram(core40,100,'normalization','pdf');  % Plot fitted histogram
hold on 
plot(x_values40,y40,'linewidth',2);
xlabel('Service Time (Hours)');
ylabel('Normalized Frequency');
title('40 Core Fit');

%% gpu Analysis

figure                      % Initial histogram of data
histogram(gpu,100);
title('gpu Partition');

xgpu = transpose(gpu);
pdgpu = fitdist(xgpu,'kernel','kernel','epanechnikov');   % Fit kernel distribution

figure
qqplot(xgpu,pdgpu);              % Create QQ plot from kernel distribution
title('gpu QQ');

[hgpu,pgpu,statsgpu] = chi2gof(xgpu,'CDF',pdgpu);   % Perform chi-squre test

x_valuesgpu = 0:0.1:40;        
ygpu = pdf(pdgpu,x_valuesgpu);      % Create sample distribution data

figure
histogram(gpu,100,'normalization','pdf');  % Plot fitted histogram
hold on 
plot(x_valuesgpu,ygpu,'linewidth',2);
xlabel('Service Time (Hours)');
ylabel('Normalized Frequency');
title('gpu Fit');

