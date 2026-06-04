opts = detectImportOptions("stimulationorder.xlsx");
opts = setvartype(opts,'double');
order = readtable("stimulationorder.xlsx", opts);
order = order.Variables;

for i = 1:size(order, 1)
    stim.anode = order(i, 1);
    stim.cathode = order(i, 2);
    stim.rampup = order(i, 3);
    stim.intensity = order(i, 4);
    stim.delay1 = order(i, 5);
    stim.duration = order(i, 6);
    stim.delay2 = order(i, 7);
end