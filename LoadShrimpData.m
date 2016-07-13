% LBF = [20,40,60,80,100];
% mV = [893,1781,2672,3564,4467];
% p = polyfit(LBF,mV,1);
% p(1) = m
% p(2) = B
% y = m*x + B

% calibration that came with sensor
p = [44.6550, -3.900];      % scale

fps = 16000;        % frames per sec in video
lastframes = 2;     % frames after trigger

window = [500*1e-6 10*1e-6];        % 500 us

[fn,pn] = uigetfile('*.tdms', 'Select TDMS files', '', 'MultiSelect', 'on');

for f = 1:length(fn)
    filename = fullfile(pn,fn{f});

    tdmsdata = TDMS_getStruct(filename);
    data = tdmsdata.Input.Sensor.data;

    dt = tdmsdata.Input.Sensor.Props.wf_increment;

    t = (0:length(data)-1)*dt;
    t = t - t(end);

    LBF = data.*p(1) + p(2);
    forceN = LBF.*4.4482;

    [forcemax, i] = max(forceN);

    before = (t > t(i)-window(1)) & (t < t(i)-window(2));
    forcebefore = mean(forceN(before));

    fprintf('%s, %f, %d\n', fn{f}, (forcemax-forcebefore), floor(t(i)*fps-lastframes));

    plot((t-t(i))*1e6, forceN, t(i),forcemax, 'r*', ...
        -window'*1e6, [forcebefore; forcebefore], 'r-');

    xlim([-window(1)*1e6 500]);
    
    pause;
end


