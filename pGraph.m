function pGraph(ana, conds, channels, options)
arguments
    ana struct
    conds
    channels (1,:) double
    options.smoothing double=0 % how much to smooth data
    options.bands char {mustBeMember(options.bands, {'sem', 'rmsSem', 'std', 'rmsStd', 'none'})}='sem' % what error band to plot
    options.tRange double=[0 1] % how to scale the time axis
    % options.tRange(1) is the x offset in point (typically -40 to move point 40 to
    % time t=0. options.tRange(2) is the deltaT per timepoint
    options.axPlot handle=[]    % where to plot the data.  Empty for new figure
    options.plotSideWays logical=false % flip the graph on its side?
    options.colorList cell={'g', 'r', 'b', 'k', 'm', 'c'}
    options.zeroLine logical=false
    options.yscaling double=1;
end

% how much smoothing to apply
if options.smoothing>1
    b = (1/options.smoothing)*ones(1,options.smoothing);
    a = 1;
else
    options.smoothing=0;
end

if ischar(conds)
    conds={conds};
end

if isempty(options.axPlot)
    figure
    options.axPlot=axes;
end

hold(options.axPlot, 'on');

mmMax=1;
mmMin=-1;

displayNames={};

colorCounter=1;
for cCounter=1:length(conds)
    cond=conds{cCounter};
    for chCounter=1:length(channels)
        channel=channels(chCounter);
        if isfield(ana.(cond), 'photometry_mean_sa_n') % it is data average across sessions and it's PHOTOMETRY
            curvemid=ana.(cond).photometry_mean{channel};
            switch options.bands
                case 'sem'
                    curvea=ana.(cond).photometry_mean_sa_hi_sem{channel};
                    curveb=ana.(cond).photometry_mean_sa_low_sem{channel};
                case 'rmsSem'
                    ciBand=ana.(cond).photometry_var{channel}.^0.5/sqrt(ana.(cond).photometry_var_sa_n(channel));
                    curvea=curvemid+ciBand;
                    curveb=curvemid-ciBand;
                case 'std'
                    ciBand=ana.(cond).photometry_mean_sa_std{channel};
                    curvea=curvemid+ciBand;
                    curveb=curvemid-ciBand;
                case 'rmsStd'
                    ciBand=ana.(cond).photometry_var{channel}.^0.5;
                    curvea=curvemid+ciBand;
                    curveb=curvemid-ciBand;
                case 'none'
                    curvea=[];
                    curveb=[];
            end
        elseif isfield(ana.(cond), 'photometry_mean') % it is a single session PHOTOMETRY
            if length(ana.(cond).photometry_mean)>=channel
                curvemid=ana.(cond).photometry_mean{channel};
                switch options.bands
                    case 'sem'
                        ciBand=ana.(cond).photometry_std{channel}/sqrt(length(ana.(cond).trialIndices));
                        curvea=curvemid+ciBand;
                        curveb=curvemid-ciBand;
                    case 'std'
                        ciBand=ana.(cond).photometry_std{channel};
                        curvea=curvemid+ciBand;
                        curveb=curvemid-ciBand;
                    otherwise
                        error('rms options do not apply to single sessions')
                end
            else
                curvemid=[];
                curvea=[];
                curveb=[];
            end
        elseif isfield(ana.(cond), 'ph_mean') % spiking data
            if length(ana.(cond).ph_mean)>=channel
                curvemid=ana.(cond).ph_mean(channel,:);
                switch options.bands
                    case 'sem'
                        ciBand=ana.(cond).ph_std(channel,:)/sqrt(length(ana.(cond).trialIndices));
                        curvea=curvemid+ciBand;
                        curveb=curvemid-ciBand;
                    case 'std'
                        ciBand=ana.(cond).ph_std(channel,:);
                        curvea=curvemid+ciBand;
                        curveb=curvemid-ciBand;
                    otherwise
                        error('rms options do not apply to single sessions')
                end
            else
                curvemid=[];
                curvea=[];
                curveb=[];
            end
        end

        if ~isempty(curvemid)
            if ~isempty(curvea)
                curvea=curvea*options.yscaling;
                curveb=curveb*options.yscaling;
            end
            curvemid=curvemid*options.yscaling;

            if options.smoothing>1
                if ~isempty(curvea)
                    curvea=filter(b, a, curvea);
                    curveb=filter(b, a, curveb);
                end
                curvemid=filter(b, a, curvemid);
                curvemid(1:options.smoothing)=nan;
            end

            xx=options.tRange(2)*((1:length(curvemid))+options.tRange(1));

            if ~strcmp(options.bands, 'none')
                fillBetween(...
                    curvea((1+options.smoothing):end), ...
                    curveb((1+options.smoothing):end), ...
                    colorName=options.colorList{colorCounter}, ...
                    axPlot=options.axPlot, ...
                    tRange=(options.tRange+[options.smoothing 0]), ...
                    plotSideWays=options.plotSideWays);
                displayNames{end+1}='';
                mMax=max(curvea);
                mMin=min(curveb);
            else
                mMax=max(curvemid);
                mMin=min(curvemid);
            end

            mmMax=max(mmMax, mMax);
            mmMin=min(mmMin, mMin);

            if options.plotSideWays
                plot(options.axPlot, curvemid, xx, ...
                    'Color', options.colorList{colorCounter}, ...
                    'LineWidth', 2);
                set(gca, 'YLim', [min(xx) max(xx)])
                displayNames{end+1}=[removeDash(cond) ' ' num2str(channel)];
                
            else
                plot(options.axPlot, xx, curvemid, ...
                    'Color', options.colorList{colorCounter}, ...
                    'LineWidth', 2);
                set(gca, 'XLim', [min(xx) max(xx)])
                displayNames{end+1}=[removeDash(cond) ' ' num2str(channel)];
            end

            colorCounter=max(mod(colorCounter+1, length(options.colorList)),1);
        else
            disp('empty')
        end
    end
end

% mmMin=max(mmMin, -5);
% mmMax=min(mmMax, 5);

if options.zeroLine
    if options.plotSideWays
        plot(options.axPlot, [mmMin mmMax], [0 0], 'k--', 'DisplayName', '')        
    else
        plot(options.axPlot, [0 0], [mmMin mmMax], 'k--', 'DisplayName', '')
    end
    displayNames{end+1}='';
end
legend(displayNames)


