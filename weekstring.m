function weekstr = weekstring(switch_day, switch_hour)
%WEEKSTRING helper function to output the string corresponding to today (if
%switch_day and later than switch_hour) or last week's string.
%
%   honesty you will probably not need to ever use this function, but
%   here's an example:
%
%   weekstring(03,12) switches the string on Tuesdays after midday.
%       If today is Tuesday 06/10/2020 14:50 the output would be
%       20201006
%
%       If today is Tuesday 06/10/2020 10:50 or before, the output would be
%       2020929 (last Tuesday)
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   see also VIBLOGGER, VIBANALYZER, SENSORS_DB


today_date = datetime();

% Tuesday = 3 because Matlab... regardless of locale! unbelievable
wday = weekday(today_date);

% find the distance between switch_day and today
dist = switch_day - wday;

% if switch_day is after today, the actual switch_day is in the past
if dist > 0
    dist = dist -7;
end

switch_datetime = today_date + days(dist);
switch_datetime.Hour = switch_hour; 
switch_datetime.Minute = 0;
switch_datetime.Second = 0;

% if we're on the switching weekday and it's after switching time, it's
% today's date folder - if not, it's last weeks'.
if ( today_date > switch_datetime)
    weekstr = datestr(switch_datetime,'YYYYmmdd');
else
    weekstr = datestr(switch_datetime - days(7),'YYYYmmdd');
end


end

