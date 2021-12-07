%% Initialization
data = readtable('New Relevent Data.csv');    % Read in data file
servicetimes = table2array(data(:,5));
e24 = [];           % Array for extended-24core partition
l24 = [];           % long-24core
l28 = [];           % long-28core

for i = 329:1464             % Exract extended-24core values from data
    if servicetimes(i) > 0.1
        e24 = [e24, servicetimes(i)];
    end
end
for i = 2266:2787            % Exract long-24core values from data
    if servicetimes(i) > 0.05
        l24 = [l24, servicetimes(i)];
    end
end
for i = 2788:3187            % Extract long-28core values from data
    if servicetimes(i) > 0.05
        l28 = [l28, servicetimes(i)];
    end
end

%% Extended 24 core
figure                      % Initial histogram of data
histogram(e24,100);
title('Extended-24 core');

xe = transpose(e24);
pde24 = fitdist(xe,'kernel','kernel','epanechnikov');   % Fit kernel distribution

figure
qqplot(xe,pde24);              % Create QQ plot from kernel distribution
title('Extended-24 Core QQ');

[he,pe,statse] = chi2gof(xe,'CDF',pde24);   % Perform chi-squre test

x_valuese24 = 0:0.1:30;        
ye24 = pdf(pde24,x_valuese24);      % Create sample distribution data

figure
histogram(e24,100,'normalization','pdf');  % Plot fitted histogram
hold on 
plot(x_valuese24,ye24,'linewidth',2);
xlabel('Service Time (Hours)');
ylabel('Normalized Frequency');
title('Extended-24 Core');


%% Long 24 core
figure
histogram(l24,100);            % Plot histogram
title('Long-24 Core');

xl24 = transpose(l24);
pdl24 = fitdist(xl24,'kernel','kernel','epanechnikov');  % fit kernel distribution

figure
qqplot(xl24,pdl24);             % create QQ plot from kernel distribution
title('Long-24 Core QQ');

[hl24,pl24,statsl24] = chi2gof(xl24,'CDF',pdl24);  % Perform chi-square test

x_valuesl24 = 0:0.1:30;
yl24 = pdf(pdl24,x_valuesl24);   % Create sample data from kernel distribution

figure
histogram(l24,100,'normalization','pdf');   % Plot fitted histogram
hold on 
plot(x_valuesl24,yl24,'linewidth',2);
title('Long-24 Core');
xlabel('Service Time (Hours)');
ylabel('Normalized Frequency');

%% Long 28 core
figure
histogram(l28,100);          % Plot histogram of data
title('Long-28 Core');

xl28 = transpose(l28);
pdl28 = fitdist(xl28,'kernel','kernel','epanechnikov');   % Fit Kernel distribution

figure
qqplot(xl28,pdl28);        % Create QQ plot
title('Long-28 Core QQ');

[hl28,pl28,statsl28] = chi2gof(xl28,'CDF',pdl28);   % Perform chi-square test

x_valuesl28 = 0:0.1:30;
yl28 = pdf(pdl28,x_valuesl28);    % Create sample data from kernel distribution

figure
histogram(l28,100,'normalization','pdf');  % Plot fitted distribution
hold on 
plot(x_valuesl28,yl28,'linewidth',2);
title('Long-28 Core');
xlabel('Service Time (Hours)');
ylabel('Normalized Frequency');

%% Total Data
service = [];
for i = 1:length(servicetimes)
    if servicetimes(i) > 0.05
        service = [service, servicetimes(i)];
    end
end

figure
histogram(service);

figure
histfit(service,50,'kernel');

x = transpose(service);
pd = fitdist(x,'kernel');

figure
qqplot(x,pd);

[h,p,stats] = chi2gof(x,'CDF',pd);



