function [label] = select_data(label)
    on = find(diff(label) > 0);
    off = find(diff(label) < 0);
    label(on:on+2000) = 0;
    label(off-2000+1:off) = 0;
end