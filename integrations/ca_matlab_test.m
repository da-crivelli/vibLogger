javaaddpath('ca-1.3.2-all.jar')
import org.epics.ca.*


dls_epics_props = java.util.Properties();
dls_epics_props.setProperty('EPICS_CA_ADDR_LIST', '10.0.0.255');


context = Context(dls_epics_props);


channel = Channels.create(context, 'S10CB01-RBOC-DCP10:FOR-AMPLT-MAX');
% Explicitly define type
%channel = Channels.create(context, ChannelDescriptor('ARIDI-PCT:CURRENT', java.lang.Double(0).getClass()));


%channel.get()
for i=1:10
    value = rand(10,1);
    pause(5)
    channel.put(value)
end

% Get metadata for channels as described in https://github.com/channelaccess/ca#metadata
%value = channel.get(org.epics.ca.data.Graphic().getClass())
%value.getUnits()

channel.close()
context.close()