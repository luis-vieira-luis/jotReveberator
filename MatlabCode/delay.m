%% Delay filter %%

function out = delay(sig_in,del)

h = dfilt.delay(del);
y = filter(h,sig_in);

out = y;

end
